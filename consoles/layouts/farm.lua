local function WORKER( host )
  return command{ 'ssh ' .. host .. ' -t "tmux new -s farm -A"' }
end

local NONE = command{ 'echo none' }

return vertical{
  [1]=horizontal{
    [1]=vertical{
      -- For thelio for some reason when we use its hostname it
      -- tries to go to its wifi address even when wifi is turned
      -- off, so we need to specify the ethernet one. We don't
      -- want to turn on its wifi and access it that way because
      -- there is a lot more latency there for some reason.
      [1]=WORKER( '192.168.1.214' ),
      [2]=WORKER( 'meerkat' ),
    },
    [2]=vertical{
      [1]=WORKER( 'bonobo' ),
      -- [2]=WORKER( 'darter2' ), -- darter2 wifi.
      [2]=WORKER( '192.168.1.75' ), -- darter2 ethernet.
    },
  },
  [2]=horizontal{
    [1]=vertical{
      [1]=WORKER( 'geekom1' ),
      [2]=WORKER( 'geekom2' ),
    },
    [2]=vertical{
      [1]=WORKER( 'geekom3' ),
      [2]=NONE,
    },
  },
}
