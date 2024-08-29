---@type string
local addonName, addon = ...
local locale = GetLocale() or "enUS"

---@type boolean
local isLoaded = false
local doUpdate = false

---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
assert(BetterBags, addonName .. " requires BetterBags")

---@class Categories: AceModule
local Categories = BetterBags:GetModule('Categories')

---@class Config: AceModule
local Config = BetterBags:GetModule('Config')

--@class Localization: AceModule
--@field G fun(self: AceModule, key: string, colorize?: boolean): string
--local L = BetterBags:GetModule('Localization')

-- Localization
local i18n = {
   enUS = {
      ["Safe Delete"] = "Safe Delete",
      ["Delete"] = "Delete",
      ["Description"] = "This plugin categorizes all items that are safe to delete from your inventory, into a category named \"Delete\". This typically includes lore-related books, letters and other trash items.\n\nThere are currently no configurable options for this plugin."
   },
   frFR = {
      ["Safe Delete"] = "Suppression sécurisée",
      ["Delete"] = "Supprimer",
      ["Description"] = "Ce plugin catégorise tous les articles qui peuvent être supprimés en toute sécurité de votre inventaire, dans une catégorie nommée \"Supprimer\". Cela inclut généralement des livres, des lettres et d'autres objets liés à l'histoire.\n\nIl n'y a actuellement aucune option configurable pour ce plugin."
   },
   ptBR = {
      ["Safe Delete"] = "Exclusão segura",
      ["Delete"] = "Excluir",
      ["Description"] = "Este plugin categoriza todos os itens que podem ser excluídos do seu inventário em uma categoria chamada \"Excluir\". Isso normalmente inclui livros relacionados à história, cartas e outros itens de lixo.\n\nNo momento, não há opções configuráveis para este plugin."
   },
   esES = {
      ["Safe Delete"] = "Eliminación segura",
      ["Delete"] = "Borrar",
      ["Description"] = "Este plugin categoriza todos los artículos que son seguros para eliminar de su inventario, en una categoría llamada \"Borrar\". Por lo general, esto incluye libros, cartas y otros artículos de basura relacionados con la tradición.\n\nActualmente no hay opciones configurables para este complemento."
   },
   esMX = {
      ["Safe Delete"] = "Eliminación segura",
      ["Delete"] = "Borrar",
      ["Description"] = "Este plugin categoriza todos los artículos que son seguros para eliminar de su inventario, en una categoría llamada \"Borrar\". Por lo general, esto incluye libros, cartas y otros artículos de basura relacionados con la tradición.\n\nActualmente no hay opciones configurables para este complemento."
   },
}
local function translate(key, colorize)
   local translation = i18n[locale] and i18n[locale][key]
   colorize = colorize or false
   if colorize then
      translation = "|cffff6666" .. translation .. "|r"
   end
   return translation or key
end

-- Add all items in equipment sets to the "Safe Delete" category
local function UpdateItems()
   for _, item in pairs(addon.deleteItems) do
      Categories:AddItemToCategory(item, translate("Delete", true))
   end
end

-- Debouce the update incase the player is making a number of inventory changes
local function DebouncedUpdateItems()
   if not doUpdate then
      doUpdate = true
      C_Timer.After(3, function()
         UpdateItems()
         doUpdate = false
      end)
   end
end

-- Register event triggers
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("BAG_UPDATE")
frame:SetScript("OnEvent", function(self, event, arg1, ...)
   if event == "ADDON_LOADED" and arg1 == addonName then
      isLoaded = true
      frame:UnregisterEvent("ADDON_LOADED")
      UpdateItems()
   elseif isLoaded and (event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" or event == "BAG_UPDATE") then
      if event == "BAG_UPDATE" then
         DebouncedUpdateItems()
      else
         UpdateItems()
      end
   end
end)

-- Register plugin with BetterBags
local options = {
   GearSetsOptions = {
      type = "group",
      name = translate("Safe Delete"),
      order = 0,
      inline = true,
      args = {
         description = {
            type = "description",
            order = 0,
            name = translate("Description"),
            fontSize = "large",
         },
      }
   }
}
Config:AddPluginConfig(translate("Safe Delete"), options)
