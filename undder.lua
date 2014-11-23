
local UndderConfig = {
	Functions = {},
	Constructors = {}
};

local UndderAdmin = {
};



function __(obj, ...)
	if (obj == nil) then
		return UndderAdmin;
	end

	if (type(obj) == "string") then
		local constr = obj:lower();
		local args = {...};

		if (UndderConfig.Constructors[constr] ~= nil) then
			return __(UndderConfig.Constructors[constr](unpack(args)));
		end
		print("Error no constructor for '" .. constr .. "'");
		return nil;
	end


	if (obj._isWrapped) then
		return obj;
	end


	local wrap = {
		Raw = obj,

		_isWrapped = true,

		_callQueue = {},
		_isTransitioning = false,
		_mark = nil,
	};


	wrap.StartTransition = function()
		wrap._isTransitioning = true;

		if (wrap._mark) then
			wrap._mark.hadTransition = true;
		end
	end

	wrap.EndTransition = function()
		wrap._isTransitioning = false;

		local queue = wrap._callQueue;

		wrap._callQueue = {};

		while (#queue > 0) do
			local action = table.remove(queue, 1);
			action.this[action.func](unpack(action.args));
		end
	end



	local mt = {
		__index = function(t, k) 

			if (t.Raw[k] ~= nil) then
				return t.Raw[k];
			end


			if (UndderConfig.Functions[k] ~= nil) then
				return function(...) 
					if (t._isTransitioning) then
						table.insert(t._callQueue, {
							func = k,
							this = t,
							args = {...}
						});
					else
						if (t._mark) then
							table.insert(t._mark.actions, {
								func = k,
								this = t,
								args = {...}
							});
						end

						UndderConfig.Functions[k](t, ...);
					end

					return t;
				end
			end

			return nil;
		end,

		__newindex = function(t, k, v) 
			t.Raw[k] = v;
		end,

		__call = function(...) 
			return UTL.EmptyFn;
		end
	};

	setmetatable(wrap, mt);
	return wrap;
end










----------------------------------------------------------------------
-- UndderAdmin functions
----------------------------------------------------------------------
function UndderAdmin.AddFunction(name, callback)
	if (UndderConfig.Functions[name] ~= nil) then
		print("Error function with name '" .. name .. "' is already registered");
		return false;
	end
	UndderConfig.Functions[name] = callback;
end


function UndderAdmin.AddConstructor(name, callback)
	name = name:lower();
	if (UndderConfig.Constructors[name] ~= nil) then
		print("Error constructor for '" .. name .. "' is already registered");
		return false;
	end
	UndderConfig.Constructors[name] = callback;
end





----------------------------------------------------------------------
-- Special functions
----------------------------------------------------------------------

UndderConfig.Functions.SetMark = function(obj)
	obj._mark = {
		hadTransition = false,
		actions = {}
	};
end


UndderConfig.Functions.GotoMark = function(obj)
	if (obj._mark == nil) then
		print("Error: You should call SetMark first");
		return;
	end

	if (obj._mark.hadTransition == false) then
		print("Error: There was no transition in between SetMark and GotoMark. This will cause infinite loop.");
		return;
	end

	obj._callQueue = obj._mark.actions;
	obj._mark = nil;
	obj.SetMark();

	obj.EndTransition();
end


----------------------------------------------------------------------
-- Constructors
----------------------------------------------------------------------

UndderConfig.Constructors.circle = function(radius)
	return display.newCircle(0, 0, radius);
end

UndderConfig.Constructors.rect = function(width, height)
	return display.newRect(0, 0, width, height);
end


UndderConfig.Constructors.text = function(text, font, fontSize, options)
	options = options or {};
	options.text = text;
	options.font = font;
	options.fontSize = fontSize;
	return display.newText(options);
end

UndderConfig.Constructors.group = function(anchorChildren, ...)
	local group = display.newGroup();
	group.anchorChildren = anchorChildren;
	
	local objects = {...};

	for i = 1, #objects do
		group:insert(objects[i].Raw);
	end
	return group;
end



----------------------------------------------------------------------
-- Position functions
----------------------------------------------------------------------
UndderConfig.Functions.XY = function(obj, x, y)
	obj.x, obj.y = x, y;
end

UndderConfig.Functions.MoveBy = function(obj, dx, dy)
	obj.x, obj.y = obj.x + dx, obj.y + dy;
end

UndderConfig.Functions.Rotate = function(obj, r)
	obj.rotation = r;
end

UndderConfig.Functions.Center = function(obj)
	obj.x, obj.y = display.contentCenterX, display.contentCenterY;
end


UndderConfig.Functions.TopLeft = function(obj)
	obj.x, obj.y = display.screenOriginX, display.screenOriginY;
end

UndderConfig.Functions.TopCenter = function(obj)
	obj.x, obj.y = display.contentCenterX, display.screenOriginY;
end

UndderConfig.Functions.TopRight = function(obj)
	obj.x, obj.y = display.contentWidth - display.screenOriginX, display.screenOriginY;
end


UndderConfig.Functions.BottomLeft = function(obj)
	obj.x, obj.y = display.screenOriginX, display.contentHeight - display.screenOriginY;
end


UndderConfig.Functions.BottomCenter = function(obj)
	obj.x, obj.y = display.contentCenterX, display.contentHeight - display.screenOriginY;
end


UndderConfig.Functions.BottomRight = function(obj)
	obj.x, obj.y = display.contentWidth - display.screenOriginX, display.contentHeight - display.screenOriginY;
end





----------------------------------------------------------------------
-- Group functions
----------------------------------------------------------------------
UndderConfig.Functions.InsertInto = function(obj, parent)
	if (parent._isWrapped) then
		parent.Raw:insert(obj.Raw);
	else
		parent:insert(obj.Raw);
	end
end

----------------------------------------------------------------------
-- Appearance functions
----------------------------------------------------------------------
UndderConfig.Functions.Alpha = function(obj, alpha)
	obj.alpha = alpha;
end

UndderConfig.Functions.Hide = function(obj)
	obj.isVisible = false;
end

UndderConfig.Functions.Show = function(obj)
	obj.isVisible = true;
end

UndderConfig.Functions.Scale = function(obj, xScale, yScale)
	yScale = yScale or xScale;
	obj.xScale, obj.yScale = xScale, yScale;
end

UndderConfig.Functions.Fill = function(obj, red, green, blue, alpha)
	if (type(red) == "table") then
		red, green, blue, alpha = unpack(red);
	end

	if (alpha == nil) then
		alpha = 1;
	end

	obj.Raw:setFillColor(red, green, blue, alpha);
end

UndderConfig.Functions.Stroke = function(obj, width, red, green, blue, alpha)
	if (type(red) == "table") then
		red, green, blue, alpha = unpack(red);
	end

	if (alpha == nil) then
		alpha = 1;
	end
	
	obj.Raw.strokeWidth = width;
	obj.Raw:setStrokeColor(red, green, blue, alpha);
end


----------------------------------------------------------------------
-- Event functions
----------------------------------------------------------------------
UndderConfig.Functions.Tap = function(obj, callback)
	obj.Raw:addEventListener("tap", callback);
end

UndderConfig.Functions.Touch = function(obj, callback)
	obj.Raw:addEventListener("touch", callback);
end


UndderConfig.Functions.TouchBegin = function(obj, callback)
	obj.Raw:addEventListener("touch", function(event)
		if (event.phase == "began") then
			return callback(event);
		end
	end);
end

UndderConfig.Functions.TouchEnd = function(obj, callback)
	obj.Raw:addEventListener("touch", function(event)
		if (event.phase == "ended") then
			return callback(event);
		end
	end);
end

UndderConfig.Functions.TouchMove = function(obj, callback)
	obj.Raw:addEventListener("touch", function(event)
		if (event.phase == "moved") then
			return callback(event);
		end
	end);
end



----------------------------------------------------------------------
-- Transition functions
----------------------------------------------------------------------

UndderConfig.Functions.TMoveBy = function(obj, dx, dy, options)
	obj.StartTransition();

	options = options or {};
	options.x, options.y = obj.Raw.x + dx, obj.Raw.y + dy;
	options.onComplete = function()
		obj.EndTransition();
	end

	transition.to(obj.Raw, options);
end

UndderConfig.Functions.TMoveByFn = function(obj, xyfunc, options)
	local dx, dy = xyfunc();
	obj.StartTransition();

	options = options or {};
	options.x, options.y = obj.Raw.x + dx, obj.Raw.y + dy;
	options.onComplete = function()
		obj.EndTransition();
	end

	transition.to(obj.Raw, options);
end



UndderConfig.Functions.Wait = function(obj, time)
	obj.StartTransition();
	timer.performWithDelay(time, function()
		obj.EndTransition();
	end);
end







----------------------------------------------------------------------
-- Misc functions
----------------------------------------------------------------------



UndderConfig.Functions.SetData = function(obj, name, value)
	obj._data = obj._data or {};
	obj._data[name] = value;
end


UndderConfig.Functions.GetData = function(obj, name, callback)
	obj._data = obj._data or {};
	callback(obj._data[name]);
end

