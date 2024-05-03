local function blast(pos, radius)
	local pos1 = vector.subtract(pos, radius)
	local pos2 = vector.add(pos, radius)

	for _, p in ipairs(minetest.find_nodes_in_area(pos1, pos2, {"group:flora", "group:dig_immediate"})) do
		if vector.distance(pos, p) <= radius then
			local node = minetest.get_node(p).name

			if node ~= "air" then
				minetest.add_item(p, node)
			end

			minetest.remove_node(p)
		end
	end
end

grenades.register_grenade("grenades_basic:frag", {
	description = "Frag grenade (Kills anyone near blast)",
	image = "grenades_basic_frag.png",
	on_explode = function(pos, name)
		print("on_explode called, pos=" .. dump(pos) .. ", name=" .. dump(name))
		if not name or not pos then
			return
		end

		local player = minetest.get_player_by_name(name)

		local radius = 6

		minetest.add_particlespawner({
			amount = 20,
			time = 0.5,
			minpos = vector.subtract(pos, radius),
			maxpos = vector.add(pos, radius),
			minvel = {x = 0, y = 5, z = 0},
			maxvel = {x = 0, y = 7, z = 0},
			minacc = {x = 0, y = 1, z = 0},
			maxacc = {x = 0, y = 1, z = 0},
			minexptime = 0.3,
			maxexptime = 0.6,
			minsize = 7,
			maxsize = 10,
			collisiondetection = true,
			collision_removal = false,
			vertical = false,
			texture = "grenades_basic_smoke.png",
		})

		minetest.add_particle({
			pos = pos,
			velocity = {x=0, y=0, z=0},
			acceleration = {x=0, y=0, z=0},
			expirationtime = 0.3,
			size = 15,
			collisiondetection = false,
			collision_removal = false,
			object_collision = false,
			vertical = false,
			texture = "grenades_basic_boom.png",
			glow = 10
		})

		minetest.sound_play("grenades_basic_explode", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 64,
		})

		blast(pos, radius/2)

		for _, obj in pairs(minetest.get_objects_inside_radius(pos, radius)) do
			local objpos = obj:get_pos()
			local hit = minetest.line_of_sight(pos, objpos)

			if hit ~= false and
					obj:get_hp() > 0 and (obj:get_luaentity() and
							not obj:get_luaentity().name:find("builtin"))
			then
				obj:punch(player,
						2,
						{damage_groups = {grenade = 1, fleshy = 90 * 0.71 ^ vector.distance(pos, objpos)}},
						vector.direction(pos, objpos)
				)
			end
		end
	end,
})

dofile(minetest.get_modpath("grenades_basic").."/crafts.lua")
