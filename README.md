# sfgml
**Quick links:** [itch.io page](https://yellowafterlife.itch.io/gamemaker-haxe) (donations, discussions)
· [GitHub wiki](https://github.com/YellowAfterlife/sfgml/wiki)
· [original documentation](https://yal.cc/r/18/sfgml/)

This library allows you to write code for GameMaker games in Haxe.

It is primarily intended for writing complex systems that are otherwise trickier to write in a language without compile-time checks.

You can find a list of things I have used it for in [this blog post](https://yal.cc/made-with-haxe/).


## Setting up
```
haxelib git sfhx https://github.com/YellowAfterlife/sfhx
haxelib git sfgml https://github.com/YellowAfterlife/sfgml
```

## Per-project setup
This implies that you have at least a very basic degree of understanding of how Haxe works.

```
haxe -debug -dce full -lib sfhx -lib sfgml -cp src -main Main -js targetPath._
```
(note: `._` suffix on the path is necessary to prevent Haxe compiler from overwriting non-code GameMaker files)

targetPath is decided as following:
GMS1:
1. Create an empty extension
2. Add a an empty GML file to it via "add placeholder"
3. targetPath is the path to .extension.gmx

GMS2 (<2.3):
1. Create an empty extension
2. Add a an empty GML file to it via "add placeholder"
3. targetPath is the path to the extension's YY file

GMS2 (≥2.3):
1. Create a new script
2. targetPath is the path to the script's YY file

So you might have
```
haxe -debug -dce full -lib sfhx -lib sfgml -cp src -main Main -js myProject/scripts/scr_haxe/scr_haxe.yy._
```

For FlashDevelop/HaxeDevelop, create a Haxe-JS project and use menu:Project➜Properties to
* Set target path in the first tab
* Add `-dce full` to Additional Compiler Options on the third tab
* Add `sfhx` and `sfgml` to library list on the third tab

## Supported features

For GameMaker Studio ≥ 2.3, things are pretty good as the language now has reflection, anonymous objects, exception handling, and overall is pretty much a beefier JS.
There are a few caveats:

- GML still doesn't have regular expressions so sfgml doesn't either.
- Bit operations are 64-bit because GML integers are 64-bit.
- Local variables are not auto-shared into closures.

For older versions, the language was more limited so there are more limitations:

- No exception handling (except for `-D sfgml_catch_error`, which utilizes [catch_error](https://yellowafterlife.itch.io/gamemaker-catch-error)).
- No reflection (apart of a few selected tricks in Type API).
- No anonymous structures (except when result is a typedef with known fields).
- No function closures.
- Normal and dynamic methods work like normal/virtual methods in C# - if you are calling a non-dynamic method,
  it will be compiled to a static reference to the target type's method implementation for performance.
- Type checking for a lot of GML externs is nonexistent since they are referenced by index.
