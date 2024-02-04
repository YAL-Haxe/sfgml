# How to [re-]generate GmlAPI# files

1. Place `fnames` from GMS2/GM2022+ in `api/`
2. If necessary, place a GMS1.x `fnames14` (rename if taken from GMS1) in `api/`
3. Open a terminal / command prompt here
4. `haxe GmlGenAPI.hxml`
5. `neko api/GmlGenAPI.n`