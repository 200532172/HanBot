return {
    id = 'TwistedKornis',
    name = 'Twisted Fate',
    riot = true,
    flag = {
      text = "Twisted Fate by Kornis",
      color = {
        text = 0xFFEDD7E6,
        background1 = 0xFFEDBBDC,
        background2 = 0x99000000
      }
    },
    load = function()
      return player.charName == 'TwistedFate'
    end
}
