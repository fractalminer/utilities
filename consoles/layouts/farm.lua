local function WORKER( host )
  return command{ 'ssh ' .. host .. ' -t "tmux new -s farm -A"' }
end

local NONE = command{ 'echo none' }

return vertical{
  [1]=horizontal{
    [1]=vertical{
      [1]=WORKER( 'thelio' ),
      [2]=WORKER( 'meerkat' ),
    },
    [2]=vertical{
      [1]=WORKER( 'bonobo' ),
      [2]=WORKER( 'darter2' ),
    },
  },
  [2]=horizontal{
    [1]=vertical{
      [1]=WORKER( 'geekom1' ),
      [2]=WORKER( 'geekom2' ),
    },
    [2]=vertical{
      [1]=NONE,
      [2]=NONE,
    },
  },
}
