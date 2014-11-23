local scene = Composer.newScene();


local function CreateScene(group, params, scene)
	local function GetXY()
		return math.random(-30, 30), math.random(-30, 30);
	end


	local function StoreXY(obj)
		obj.storedX, obj.storedY = obj.x, obj.y;
	end

	local function MarkPath(obj, color)
		if (obj.pathLine == nil) then
			obj.pathLine = display.newLine(obj.storedX, obj.storedY, obj.x, obj.y);
			obj.pathLine:setStrokeColor(unpack(color));
			obj.pathLine.strokeWidth = 5;
		else
			obj.pathLine:append(obj.x, obj.y);
		end
	end

	local fills = {{1, 1, 0}, {1, 0, 1}, {0, 1, 1}};
	local strokes = {{0.3, 0.3, 0}, {0.3, 0, 0.3}, {0, 0.3, 0.3}};

	__().AddFunction("StoreXY", StoreXY);
	__().AddFunction("MarkPath", MarkPath);

	for i = 1, 3 do
	
		local c = __("Circle", 10)
						.Stroke(5, strokes[i])
						.Fill(fills[i])
						.Center()
						.SetMark()
						.StoreXY()
						.Wait(30)
						.TMoveByFn(GetXY, { time = 30 })
						.MarkPath(fills[i])
						.GotoMark();
	end

end



function scene:create( event )
    local sceneGroup = self.view
    Composer.removeHidden();
    CreateScene(sceneGroup, event.params, scene);
    CreateBackButton(sceneGroup);
end


scene:addEventListener("create", scene);
return scene;