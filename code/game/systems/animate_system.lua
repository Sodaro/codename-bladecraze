local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"

local animate_query = entity_query.all(components.animation)

-- // Updates the animation by ticking the animation time and sets the current quad
local function update_animation(animation, dt)
  animation.current_time = animation.current_time + dt

  if animation.current_time > animation.duration then
    animation.current_time = 0
  end

  animation.current_quad = animation.quads[
      1 + math.floor((animation.current_time / animation.duration) * #animation.quads)]
  _, _, animation.viewport.x, animation.viewport.y = animation.current_quad:getViewport()

  return animation
end

local animation_set_state_system = system(animate_query, function(self, dt)
  local animation, velocity, current_animation = nil, nil, nil

  self:for_each(function(entity)
    animation = entity[components.animation]
    velocity = entity[components.velocity]

    current_animation = animation[animation.current_animation_state]

    if not animation.freeze_frame then
      update_animation(current_animation, dt)
    end

    if animation.current_animation_state == ANIMATION_STATE_TYPES.WALKING then
      if velocity.x > 0 then
        animation.direction = 1
      elseif velocity.x < 0 then
        animation.direction = -1
      end
    end
  end)
end)

return animation_set_state_system