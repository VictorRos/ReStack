-- Barrel stack and capacity
-- filled barrels are auto generated from fluids in base\data-updates.lua
local barrel_stack_size = settings.startup["ReStack-barrel-stack"].value
local barrel_capacity = settings.startup["ReStack-barrel-fill"].value
local empty_barrel = "empty-barrel"

-- instead of 1 barrel ever 0.2 we default to 10 barrels every 2
local energy_per_recipe = 2
local recipe_barrel_multiplier = 10
if barrel_capacity < 500 then -- each recipe should at least process the base 50L
  recipe_barrel_multiplier = math.ceil(500 / barrel_capacity)
else
  energy_per_recipe = math.floor(barrel_capacity / 250)
end
-- log("[RS] barrel capacity: "..barrel_capacity.." (50), barrels per recipe: "..recipe_barrel_multiplier.." (1), energy per recipe: "..energy_per_recipe.." (0.2)")

-- set barrel stack size
data.raw.item[empty_barrel].stack_size = barrel_stack_size
log("[RS] Setting item."..tostring(data.raw.item[empty_barrel].name)..".stack_size "..barrel_stack_size)
for fluid_name, fluid in pairs(data.raw.fluid) do
  if (fluid.auto_barrel == nil or fluid.auto_barrel) and (fluid.icon or fluid.icons) then
    local barrel_name = fluid_name.."-barrel" -- naming convention is hardcoded in base\data-update.lua
    local barrel_item = data.raw.item[barrel_name]
    if barrel_item then
      barrel_item.stack_size = barrel_stack_size
      log("[RS] Setting item."..tostring(barrel_item.name)..".stack_size "..barrel_stack_size)
    end

    -- adjust barrel capacity and recipes
    local fill_recipe = data.raw.recipe["fill-"..barrel_name]
    if fill_recipe then
      log("[RS] Setting fill recipe."..tostring(fill_recipe.name).." to "..recipe_barrel_multiplier.."x "..barrel_capacity.."L barrel every "..energy_per_recipe)
      fill_recipe.energy_required = energy_per_recipe
      for _, ingredient in pairs(fill_recipe.ingredients) do
        if ingredient.name == empty_barrel then
          ingredient.amount = ingredient.amount * recipe_barrel_multiplier
        end
        if ingredient.name == fluid_name then
          ingredient.amount = barrel_capacity * recipe_barrel_multiplier
        end
      end
      for _, result in pairs(fill_recipe.results) do
        if result.name == fluid_name.."-barrel" then
          result.amount = result.amount * recipe_barrel_multiplier
        end
      end
    end

    local empty_recipe = data.raw.recipe["empty-"..barrel_name]
    if empty_recipe then
      log("[RS] Setting empty recipe."..tostring(empty_recipe.name).." to "..recipe_barrel_multiplier.."x "..barrel_capacity.."L barrel every "..energy_per_recipe)
      empty_recipe.energy_required = energy_per_recipe
      for _, ingredient in pairs(empty_recipe.ingredients) do
         if ingredient.name == fluid_name.."-barrel" then
          ingredient.amount = ingredient.amount * recipe_barrel_multiplier
        end
      end
      for _, result in pairs(empty_recipe.results) do
        if result.name == empty_barrel then
          result.amount = result.amount * recipe_barrel_multiplier
        end
        if result.name == fluid_name then
          result.amount = barrel_capacity * recipe_barrel_multiplier
        end
      end
    end

  end
end