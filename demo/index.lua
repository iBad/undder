
local scene = Composer.newScene();


function CreateBackButton(group)
	__("Group", true,
		__("Rect", 160, 60).Fill(0.6, 0.6, 0.6),
		__("Text", "Back", nil, 48).Fill(0.6, 1, 0.6)
	).InsertInto(group).Tap(function()
		Composer.gotoScene("demo.index");
	end).TopLeft().MoveBy(90, 100);
end


local function OnButtonTap(event)
	__(event.target).GetData("scene", Composer.gotoScene);
end

	
local function CreateButton(scene, text)
	return __("Group", true,
					__("Rect", 600, 100).Fill(0.6, 0.6, 0.6),
					__("Text", text, nil, 48).Fill(0.6, 1, 0.6)
			).SetData("scene", scene).Tap(OnButtonTap);
end


local function CreateScene(group, params, scene)
	__().AddConstructor("Button", CreateButton);

	local scenes = {
		["demo.s1"] = "Demo random walk"
	};

	local group = __("Group", true).InsertInto(group).Center();
	for k,v in pairs(scenes) do
		__("Button", k, v).InsertInto(group);
	end
end



function scene:create( event )
    local sceneGroup = self.view
    Composer.removeHidden();
    CreateScene(sceneGroup, event.params, scene);
end


scene:addEventListener("create", scene);
return scene;