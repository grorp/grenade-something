grenades = {
	grenade_accel = 13
}

local function throw_grenade(name, player)
	local dir = player:get_look_dir()
	local pos = player:get_pos()
	pos.y = pos.y + player:get_properties().eye_height
	local obj = minetest.add_entity(pos, name)

	local m = 30
	obj:set_velocity({x = dir.x * m, y = dir.y * m/1.5, z = dir.z * m})
	obj:set_acceleration({x = 0, y = -13, z = 0})

	return(obj:get_luaentity())
end

function grenades.register_grenade(name, def)
	if not def.clock then
		def.clock = 4
	end

	local grenade_entity = {
		physical = true,
		sliding = 1,
		collide_with_objects = true,
		visual = "sprite",
		visual_size = {x = 0.5, y = 0.5, z = 0.5},
		textures = {def.image},
		collisionbox = {-0.2, -0.3, -0.2, 0.2, 0.15, 0.2},
		pointable = false,
		static_save = false,
		particle = 0,
		timer = 0,
		on_step = function(self, dtime, moveresult)
			if moveresult.collides then
				print(dump(moveresult))
				print(dump(moveresult.collisions))
				print(dump(moveresult.collisions[1]))
				print(dump(moveresult.collisions[1].new_pos))
				local pos = moveresult.collisions[1].new_pos
				if self.thrower_name then
					minetest.log("[Grenades] A grenade thrown by " .. self.thrower_name ..
					" explodes at " .. minetest.pos_to_string(vector.round(pos)))
					def.on_explode(pos, self.thrower_name)
				end

				self.object:remove()
			end
		end
	}

	minetest.register_entity(name, grenade_entity)

	local newdef = {}

	newdef.description = def.description
	newdef.stack_max = 1
	newdef.range = 0
	newdef.inventory_image = def.image
	newdef.on_use = function(itemstack, user, pointed_thing)
		local player_name = user:get_player_name()

		if pointed_thing.type ~= "node" then
			local grenade = throw_grenade(name, user)
			grenade.thrower_name = player_name

			if not minetest.settings:get_bool("creative_mode") then
				itemstack = ""
			end
		end

		return itemstack
	end

	if def.placeable == true then

		newdef.tiles = {def.image}
		newdef.selection_box = {
			type = "fixed",
			fixed = {-0.3, -0.5, -0.3, 0.3, 0.4, 0.3},
		}
		newdef.groups = {oddly_breakable_by_hand = 2}
		newdef.paramtype = "light"
		newdef.sunlight_propagates = true
		newdef.walkable = false
		newdef.drawtype = "plantlike"

		minetest.register_node(name, newdef)
	else
		minetest.register_craftitem(name, newdef)
	end

	minetest.register_craftitem(name, newdef)
end
