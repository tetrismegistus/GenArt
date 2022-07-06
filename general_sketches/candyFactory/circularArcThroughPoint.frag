#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec3 u_mouse;
uniform float u_time;

float m_Centerx;
float m_Centery;
float m_dRadius;

float plot(vec2 st, float pct) {
    return smoothstep(pct - 0.2, pct, st.y) - 
           smoothstep(pct, pct + 0.02, st.y);
}

float sq(float x) {
    return x * x;
}

bool IsPerpendicular(float pt1x, float pt1y, float pt2x, float pt2y, float pt3x, float pt3y){
	//Check if the given points are perpendicular to x or y axis
	float yDelta_a = pt2y - pt1y;
    float xDelta_a = pt2x - pt1x;
    float yDelta_b = pt3y - pt2y;
    float xDelta_b = pt3x - pt2x;
    float epsilon = 0.000001;

    // checking whether the line of the two pts are vertical
    if (abs(xDelta_a) <= epsilon && abs(yDelta_b) <= epsilon) {
        return false;
    }
    if (abs(yDelta_a) <= epsilon) {
        return true;
    } else if (abs(yDelta_b) <= epsilon) {
        return true;
    } else if (abs(xDelta_a) <= epsilon) {
        return true;
    } else if (abs(xDelta_b) <= epsilon) {
        return true;
    } else {
        return false;
    }
}

void calcCircleFrom3Points (
    float pt1x, float pt1y,
    float pt2x, float pt2y,
    float pt3x, float pt3y) {
    
    float yDelta_a = pt2y - pt1y;
    float xDelta_a = pt2x - pt1x;
    float yDelta_b = pt3y - pt2y;
    float xDelta_b = pt3x - pt2x;
    float epsilon = 0.000001;

    if (abs(xDelta_a) <= epsilon && abs(yDelta_b) <= epsilon) {
        m_Centerx = 0.5*(pt2x + pt3x);
        m_Centery = 0.5*(pt1y + pt2y);
        m_dRadius = sqrt(sq(m_Centerx-pt1x) + sq(m_Centery-pt1y));
        return;        
    }

    // IsPerpendicular() assures that xDelta(s) are not zero
    float aSlope = yDelta_a / xDelta_a;
    float bSlope = yDelta_b / xDelta_b;
    if (abs(aSlope-bSlope) <= epsilon) {
        // checking whether the points are colinear
        return;
    }

    // calc center
    m_Centerx = (aSlope*bSlope*(pt1y - pt3y) +
                 bSlope*(pt1x + pt2x) -
                 aSlope*(pt2x+pt3x)) / 
                 (2*(bSlope-aSlope));
    m_Centery = -1*(m_Centerx - (pt1x+pt2x)/2)/aSlope + (pt1y+pt2y)/2;
    m_dRadius = sqrt(sq(m_Centerx-pt1x) + sq(m_Centery-pt1y));
}

float circularArcThroughAPoint(float x, float a, float b) {
    float epsilon = 0.00001;
    float min_param_a = 0.0 + epsilon;
    float max_param_a = 1.0 - epsilon;
    float min_param_b = 0.0 + epsilon;
    float max_param_b = 1.0 - epsilon;
    a = min(max_param_a, max(min_param_a, a));
    b = min(max_param_b, max(min_param_b, b));
    x = min(1.0-epsilon, max(0.0+epsilon, x));

    float pt1x = 0;
    float pt1y = 0;
    float pt2x = a;
    float pt2y = b;
    float pt3x = 1;
    float pt3y = 1;

 	if      (!IsPerpendicular(pt1x,pt1y, pt2x,pt2y, pt3x,pt3y))		
		calcCircleFrom3Points (pt1x,pt1y, pt2x,pt2y, pt3x,pt3y);	
	else if (!IsPerpendicular(pt1x,pt1y, pt3x,pt3y, pt2x,pt2y))		
    	calcCircleFrom3Points (pt1x,pt1y, pt3x,pt3y, pt2x,pt2y);	
	else if (!IsPerpendicular(pt2x,pt2y, pt1x,pt1y, pt3x,pt3y))		
	    calcCircleFrom3Points (pt2x,pt2y, pt1x,pt1y, pt3x,pt3y);	
	else if (!IsPerpendicular(pt2x,pt2y, pt3x,pt3y, pt1x,pt1y))		
	    calcCircleFrom3Points (pt2x,pt2y, pt3x,pt3y, pt1x,pt1y);	
	else if (!IsPerpendicular(pt3x,pt3y, pt2x,pt2y, pt1x,pt1y))		
	    calcCircleFrom3Points (pt3x,pt3y, pt2x,pt2y, pt1x,pt1y);	
	else if (!IsPerpendicular(pt3x,pt3y, pt1x,pt1y, pt2x,pt2y))		
	    calcCircleFrom3Points (pt3x,pt3y, pt1x,pt1y, pt2x,pt2y);	
	else { 
		return 0;
	}

	// constrain
	if ((m_Centerx > 0) && (m_Centerx < 1)) {
		if (a < m_Centerx) {
			m_Centerx = 1.0;
			m_Centery = 0.0;
			m_dRadius = 1.0;
		} else {
			m_Centerx = 0.0;
			m_Centery = 1.0;
			m_dRadius = 1.0;
		}
	}

	float y = 0;
	if (x >= m_Centerx) {
		y = m_Centery - sqrt(sq(m_dRadius) - sq(x-m_Centerx));
	} else {
		y = m_Centery + sqrt(sq(m_dRadius) - sq(x-m_Centerx));
	}
	return y;
}

	


void main() {
    vec2 st = gl_FragCoord.st/u_resolution;
    float y = circularArcThroughAPoint(st.x, 0.5, 0.747);
    vec3 color = vec3(y);

    //Plot a line
    float pct = plot(st, y);
    color = (1.0 - pct) * color + pct * vec3(0.0, 1.0, 0.0);
    gl_FragColor = vec4(color, 1.0);
}

