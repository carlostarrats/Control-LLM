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

vertex VertexOut rippleVertexShader(uint vertexID [[vertex_id]],
                                   constant float* vertices [[buffer(0)]]) {
    VertexOut out;
    out.position = float4(vertices[vertexID * 5], vertices[vertexID * 5 + 1], 0, 1);
    out.texCoord = float2(vertices[vertexID * 5 + 3], vertices[vertexID * 5 + 4]);
    return out;
}

        // Simple, visible fluid simulation for ripple effect
        float createSimpleFluidRipple(float2 p, float time, float2 center, float baseRadius) {
            float2 toCenter = center - p;
            float distToCenter = length(toCenter);
            
            // Create a simple expanding ring with fluid-like properties
            float ringRadius = baseRadius;
            float ringWidth = 40.0; // Thick ring for visibility
            
            // Calculate distance from the ideal ripple ring
            float distFromRing = abs(distToCenter - ringRadius);
            
            // Create the main ripple ring
            float ringDensity = 0.0;
            if (distFromRing < ringWidth) {
                // Smooth falloff from center of ring
                float normalizedDist = distFromRing / ringWidth;
                ringDensity = 1.0 - normalizedDist;
                
                // Add some organic variation to the ring
                float angle = atan2(toCenter.y, toCenter.x);
                float organicVariation = sin(angle * 8.0 + time * 2.0) * 0.3 + 0.7;
                ringDensity *= organicVariation;
            }
            
            // Add some internal fluid movement within the ring
            float internalFluid = 0.0;
            if (distFromRing < ringWidth * 0.8) {
                float2 relativePos = p - center;
                float internalAngle = atan2(relativePos.y, relativePos.x);
                
                // Create flowing patterns within the ring
                float flow1 = sin(internalAngle * 3.0 + time * 1.5) * 0.4;
                float flow2 = cos(internalAngle * 5.0 + time * 0.8) * 0.3;
                float flow3 = sin(relativePos.x * 0.02 + time * 2.0) * 0.2;
                float flow4 = cos(relativePos.y * 0.02 + time * 1.2) * 0.2;
                
                internalFluid = (flow1 + flow2 + flow3 + flow4) * 0.5;
            }
            
            // Combine ring and internal fluid
            float totalFluid = ringDensity + internalFluid;
            
            // Add some turbulence around the edges
            if (distFromRing < ringWidth * 1.2) {
                float turbulence = sin(p.x * 0.03 + time * 1.8) * 
                                 sin(p.y * 0.03 + time * 1.4) * 0.2;
                totalFluid += turbulence;
            }
            
            return max(0.0, totalFluid);
        }

fragment float4 rippleFragmentShader(float2 texCoord [[stage_in]],
                                    constant float* uniforms [[buffer(0)]]) {
    float time = uniforms[0];
    float isActive = uniforms[1];
    float screenWidth = uniforms[2];
    float screenHeight = uniforms[3];
    
    // Convert texture coordinates to screen coordinates
    float2 p = (texCoord - 0.5) * float2(screenWidth, screenHeight);
    
    // Center of the screen for ripple origin
    float2 center = float2(0.0, 0.0);
    
    // Base ripple radius that expands over time - start larger and expand faster
    float baseRadius = 100.0 + time * 300.0;
    
    // Only show ripple when active
    if (isActive < 0.5) {
        return float4(0.0, 0.0, 0.0, 0.0); // Transparent when not active
    }
    
                // Generate simple fluid simulation for ripple effect
            float fluidDensity = createSimpleFluidRipple(p, time, center, baseRadius);
            
            // Debug: Force a simple visible ripple for testing
            float2 toCenter = center - p;
            float distToCenter = length(toCenter);
            float simpleRipple = 0.0;
            
            // Create a simple expanding circle that's always visible
            // Make it much thicker and more visible from the start
            if (distToCenter < baseRadius + 100.0 && distToCenter > baseRadius - 100.0) {
                simpleRipple = 1.0;
            }
            
            // Also add a center dot that's always visible when active
            float centerDot = 0.0;
            if (distToCenter < 80.0) {
                centerDot = 1.0;
            }
            
            // Use the simple ripple instead of complex fluid simulation
            float finalDensity = max(fluidDensity, max(simpleRipple, centerDot));
            
            // Apply minimum density threshold to reduce gaps
            finalDensity = max(finalDensity, 0.1);
            
            // Create defined boundaries - fluid or nothing - very low threshold for visibility
            if (finalDensity < 0.1) {
                return float4(0.0, 0.0, 0.0, 0.0); // Transparent - no fluid
            }
            
            // Apply smooth boundaries for defined fluid shapes
            float smoothBoundary = smoothstep(0.1, 0.4, finalDensity);
            
            // Create the ripple effect with bright red color for maximum visibility
            float3 color = float3(1.0, 0.0, 0.0); // Bright red ripple for testing
            float alpha = smoothBoundary * 1.0; // Fully opaque for visibility
            
            // Fade out ripples as they expand
            float maxRadius = sqrt(screenWidth * screenWidth + screenHeight * screenHeight) * 0.4;
            if (baseRadius > maxRadius) {
                float fadeProgress = (baseRadius - maxRadius) / (maxRadius * 0.5);
                alpha *= max(0.0, 1.0 - fadeProgress);
            }
            
            // Ensure minimum alpha for visibility - make it always visible when active
            alpha = max(alpha, 0.8);
            
            // Force full opacity for the simple ripple parts
            if (simpleRipple > 0.5 || centerDot > 0.5) {
                alpha = 1.0;
                color = float3(0.0, 1.0, 0.0); // Green for the simple parts
            }
            
            return float4(color, alpha);
}
