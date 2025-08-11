#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertexShader(uint vertexID [[vertex_id]],
                              constant float* vertices [[buffer(0)]]) {
    VertexOut out;
    out.position = float4(vertices[vertexID * 5], vertices[vertexID * 5 + 1], 0, 1);
    out.texCoord = float2(vertices[vertexID * 5 + 3], vertices[vertexID * 5 + 4]);
    return out;
}

// Fluid particle simulation - KEEPING EXACTLY THE SAME
struct FluidParticle {
    float2 position;
    float2 velocity;
    float density;
    float life;
};

// Generate fluid particles along ring path - KEEPING EXACTLY THE SAME
float2 getRingPosition(float angle, float radius, float time) {
    // Add some organic variation to the ring path
    float radiusVariation = sin(angle * 3.0 + time * 0.5) * 5.0 + 
                           sin(angle * 7.0 + time * 0.3) * 3.0;
    float finalRadius = radius + radiusVariation;
    
    return float2(cos(angle) * finalRadius, sin(angle) * finalRadius);
}

// Simulate fluid particle behavior - KEEPING EXACTLY THE SAME
float simulateFluidParticle(float2 p, float time, float ringRadius) {
    float2 center = float2(0.0, 0.0);
    float2 toCenter = center - p;
    float distToCenter = length(toCenter);
    
    // Create ring path for fluid to follow
    float preferredRadius = ringRadius;
    float ringAttraction = exp(-pow(distToCenter - preferredRadius, 2.0) / 2000.0);
    
    // Generate multiple fluid particles along the ring
    float totalDensity = 0.0;
    
    // Create 8 fluid particles around the ring
    for (int i = 0; i < 8; i++) {
        float angle = float(i) * 2.0 * M_PI_F / 8.0 + time * 0.2;
        float2 particlePos = getRingPosition(angle, preferredRadius, time);
        
        // Add some organic movement to particles
        float2 offset = float2(sin(time * 0.7 + float(i) * 0.5) * 15.0,
                              cos(time * 0.6 + float(i) * 1.2) * 15.0);
        particlePos += offset;
        
        // Calculate distance to this particle
        float distToParticle = length(p - particlePos);
        
        // Create defined fluid shape with clear boundaries
        float particleDensity = 0.0;
        if (distToParticle < 25.0) {
            // Sharp, defined boundary for fluid shape
            float normalizedDist = distToParticle / 25.0;
            particleDensity = (1.0 - normalizedDist) * (1.0 - normalizedDist);
            
            // Add some internal structure to the fluid
            float internalStructure = sin(p.x * 0.1 + time * 0.8) * 
                                   sin(p.y * 0.1 + time * 0.6) * 0.3;
            particleDensity += internalStructure;
        }
        
        // Add particle to total density
        totalDensity += particleDensity;
    }
    
    // Apply ring attraction to keep fluid on the ring path
    totalDensity *= ringAttraction;
    
    // Create additional fluid flow along the ring
    float flowDensity = 0.0;
    float angle = atan2(toCenter.y, toCenter.x);
    
    // Simulate flowing fluid along the ring circumference
    for (int j = 0; j < 12; j++) {
        float flowAngle = angle + float(j) * 0.5 + time * 0.4;
        float2 flowPos = getRingPosition(flowAngle, preferredRadius, time);
        
        float distToFlow = length(p - flowPos);
        if (distToFlow < 20.0) {
            float flowStrength = (1.0 - distToFlow / 20.0) * 0.6;
            flowDensity += flowStrength;
        }
    }
    
    return totalDensity + flowDensity;
}

// Create overlapping fluid layers for depth - KEEPING EXACTLY THE SAME
float createFluidLayers(float2 p, float time, float ringRadius) {
    // Base fluid layer
    float baseFluid = simulateFluidParticle(p, time, ringRadius);
    
    // Second layer with different timing
    float secondLayer = simulateFluidParticle(p, time * 1.3, ringRadius);
    
    // Third layer for additional depth
    float thirdLayer = simulateFluidParticle(p, time * 0.8, ringRadius);
    
    // Blend layers for overlapping effect
    float blended = baseFluid * 0.5 + secondLayer * 0.3 + thirdLayer * 0.2;
    
    // Add some turbulence for organic movement
    float turbulence = sin(p.x * 0.02 + time * 0.9) * 
                     sin(p.y * 0.02 + time * 0.7) * 0.2;
    
    return blended + turbulence;
}

fragment float4 fragmentShader(float2 texCoord [[stage_in]],
                               constant float* uniforms [[buffer(0)]]) {
    float time = uniforms[0];
    float ringRadius = uniforms[1];
    
    // Convert texture coordinates to centered coordinates
    float2 p = (texCoord - 0.5) * 400.0;
    
    // Generate fluid simulation along ring path - KEEPING EXACTLY THE SAME
    float fluidDensity = createFluidLayers(p, time, ringRadius);
    
    // Apply minimum density threshold to reduce gaps
    fluidDensity = max(fluidDensity, 0.05);
    
    // Create defined boundaries - fluid or nothing - KEEPING EXACTLY THE SAME
    if (fluidDensity < 0.1) {
        return float4(0.0, 0.0, 0.0, 0.0); // Transparent - no fluid
    }
    
    // Apply sharp boundaries for defined fluid shapes - KEEPING EXACTLY THE SAME
    float sharpBoundary = smoothstep(0.1, 0.3, fluidDensity);
    
    // Convert to white/grey with defined boundaries - KEEPING EXACTLY THE SAME
    float3 color = float3(sharpBoundary * 0.9 + 0.1);
    
    // Create overlapping, transparent layers - KEEPING EXACTLY THE SAME
    float alpha = sharpBoundary * 0.8; // Semi-transparent for layering
    
    // Force transparency - ensure no background color leaks through
    if (alpha < 0.01) {
        return float4(0.0, 0.0, 0.0, 0.0); // Force transparent for very low alpha
    }
    
    // Try a different approach - ensure no color output when alpha is very low
    if (alpha < 0.05) {
        return float4(0.0, 0.0, 0.0, 0.0); // Force transparent for low alpha
    }
    
    // Only output color when we have meaningful fluid density
    if (fluidDensity < 0.15) {
        return float4(0.0, 0.0, 0.0, 0.0); // Force transparent for low density
    }
    
    // Try a completely different approach - only output when we have significant fluid
    if (fluidDensity < 0.2) {
        return float4(0.0, 0.0, 0.0, 0.0); // Force transparent for low density
    }
    
    // Ensure alpha is meaningful before outputting anything
    if (alpha < 0.1) {
        return float4(0.0, 0.0, 0.0, 0.0); // Force transparent for low alpha
    }
    
    return float4(color, alpha);
}
