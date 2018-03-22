extends Node

static func start2(t): return t * t
static func start3(t): return t * t * t
static func start4(t): return t * t * t * t
static func start5(t): return t * t * t * t * t
static func start6(t): return t * t * t * t * t * t
static func start7(t): return t * t * t * t * t * t * t

static func stop2(t): return 1 - (1 - t) * (1 - t) 
static func stop3(t): return 1 - (1 - t) * (1 - t) * (1 - t) 
static func stop4(t): return 1 - (1 - t) * (1 - t) * (1 - t) * (1 - t) 
static func stop5(t): return 1 - (1 - t) * (1 - t) * (1 - t) * (1 - t) * (1 - t) 
static func stop6(t): return 1 - (1 - t) * (1 - t) * (1 - t) * (1 - t) * (1 - t) * (1 - t) 
static func stop7(t): return 1 - (1 - t) * (1 - t) * (1 - t) * (1 - t) * (1 - t) * (1 - t) * (1 - t) 

static func flip(t): return 1 - t

static func blend(t, smootha, smoothb, weight): return (1 - weight) * smootha + weight * smoothb
static func cross(t, smootha, smoothb): return blend(t, smootha, smoothb, t)

static func scale(t, smootha): return t * smootha
static func rev_scale(t, smootha): return (1 - t) * smootha

static func arch(t, w=1): return scale(t * w, flip(t))

static func linear_interp(a, b, t):
	return a + (b - a) * t

static func radial_interpolate(a, b, t):
	var dot = a.dot(b)
	var res
	
	if dot >= 0:
		res = linear_interp(a, b, t)
	elif dot >= -0.5:
		var half = (a + b)/2
		res = cross(t, linear_interp(a, half, t), linear_interp(half, b, t))
	else:
		var half = b.tangent()
		half = half * (1 if a.dot(half) > 0 else -1)
		res = cross(t, linear_interp(a, half, t), linear_interp(half, b, t))
	
	return res.normalized()

# moving! positive if to the right, negative if to the left of stationary
static func perp_prod(stationary, moving):
	return stationary.dot(moving.tangent())

static func directed_radial_interpolate(a, b, t, dir):
	var dot = a.dot(b)
	var right = perp_prod(a, b) >= 0
	var dir_right = dir > 0
	var res
	
	
	if dot >= -0.5 and dir_right != right:

		res = linear_interp(a, b, t)
	
	elif dot > -0.5:

		
		var seg1 = a.tangent() * dir
		var seg2 = seg1.tangent() * dir

		res = cross(t, cross(t, linear_interp(a, seg1, t), linear_interp(seg1, seg2, t)), linear_interp(seg2, b, t))

	else:

		var half = a.tangent() * dir

		res = cross(t, linear_interp(a, half, t), linear_interp(half, b, t))
	
	return res.normalized()




static func graph(owner, method, size=150, offset=Vector2(), step=0.01):
	var points = PoolVector2Array()
	
	var t = 0
	while t < 1:
		points.append(Vector2(t * size, -owner.call(method, t) * size) + offset)
		t += step
	
	return points

