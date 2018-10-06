local BaseUltChampions = {
  Jinx = true,
  Ezreal = true,
  Ashe = true,
  Draven = true
}
return {
  id = "BaseUltKornis",
  name = "BaseUlt - " .. player.charName,
  riot = true,
  flag = {
    text = "BaseUlt by Kornis",
    color = {
      text = 0xFFEDD7E6,
      background1 = 0xFFFF69B4,
      background2 = 0x59000000
    }
  },
  load = function()
    return BaseUltChampions[player.charName]
  end
}
