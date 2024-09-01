#define PI 3.1415926535
#define TAU 6.2831853071

const float thickness = 0.2;
const float pivotPosition = 0.45;
const float pivotRadius = max(0.0, 1.0 - thickness - pivotPosition);
const float border = 0.35;

const float edgeLength = max(0.0, pivotPosition * 2.0);
const float cornerLength = pivotRadius * TAU / 4.0;
const float segmentLength = edgeLength + cornerLength;

float getHueAt(vec2 p)
{
    int i = p.x > 0.0  ? (p.y > 0.0 ? 0 : 3) : (p.y > 0.0 ? 1 : 2);

    p = abs(p);
    p = i == 1 || i == 3 ? p.yx : p.xy;

    float f = (p.x >= pivotPosition && p.y >= pivotPosition) ? 0.5 * edgeLength :
        (p.x < p.y ? (edgeLength * (1.0 - 0.5 * p.x / pivotPosition)) : (0.5 * edgeLength * p.y / pivotPosition));

    f = (edgeLength * float(i) + f);

    float an = (p.x <= pivotPosition && p.y <= pivotPosition) ? (p.x < p.y ? 1.0 : 0.0) :
        (2.0 * atan(max(0.0, p.y - pivotPosition), max(0.0, p.x - pivotPosition)) / PI);

    an = cornerLength * (float(i) + an);

    float h = (an + f) / (4.0 * segmentLength);
    h = fract(-(h + 0.5));
    return h;
}

float sdPicker(vec2 p)
{
    p = abs(p);
    if (1.0 - pivotPosition < 2.0 * thickness && p.x < 1.0 - 2.0 * thickness && p.y < 1.0 - 2.0 * thickness)
    {
        return 0.0;
    }

    p = vec2(max(0.0, p.x - pivotPosition), max(0.0, p.y - pivotPosition));

    return length(p);
}

int getMask(vec2 p)
{
    float d = sdPicker(p);

    return
        d <= pivotRadius - thickness ? 0 :
        d <= pivotRadius + thickness ? 1 :
        d <= pivotRadius + thickness + border ? 2 : 3;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 p = fragCoord/iResolution.xy;
    p = 2.0 * p - 1.0;

    p.x *= iResolution.x / iResolution.y;
    p *= 1.5;

    float h = getHueAt(p);
    float h2 = 0.3 - h;

    vec3 col = vec3(sin(h2 * TAU), sin((h2 + 0.33) * TAU), sin((h2 + 0.66) * TAU)) * 0.5 + 0.7;

    int mask = getMask(p);

    col = mask == 0 || mask == 2 ? vec3(0.0) :
          mask == 1 ? col : vec3(1.0);

    fragColor = vec4(col, 1.0);
}
