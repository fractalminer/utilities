local WORKER = command{ '/home/dsicilia/dev/redist/src/run-worker.sh' }

return horizontal{
  [1]=vertical{
    [1]=WORKER,
    [2]=WORKER,
  },
  [2]=vertical{
    [1]=WORKER,
    [2]=WORKER,
  },
}
