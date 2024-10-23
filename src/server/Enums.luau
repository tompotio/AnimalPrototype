local Enums = {}

export type FoodType = number

Enums.FoodType = {
    INSECT = "INSECT",
    FRUIT = "FRUIT",
    EGG = "EGG",
    MEERKAT = "MEERKAT"
}

export type Entity = number
Enums.Entity = {}
for name, foodTypeNumber in Enums.FoodType do 
    Enums.Entity[name] = foodTypeNumber
end
Enums.Entity["JACKAL"] = "JACKAL"

return Enums