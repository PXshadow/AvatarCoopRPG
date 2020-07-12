import h2d.Drawable;
import hxd.Event;
import echo.Line;
import hxd.Cursor;
import format.abc.Data.ABCData;
import haxe.ds.List;
import echo.Body;
import echo.World;
import h2d.Scene;
import h2d.Camera;
import ogmo.Entity;
import hxd.Pixels;
import h2d.Tile;
import h2d.Text;
import h2d.Font;
import hxd.res.DefaultFont;
import h2d.Graphics;
import hxd.Res;
import echo.Echo;
import Entity;
import echo.util.Debug;
import hxd.Key;

class Main extends hxd.App {
	public static var world:World;
	private static var cursor:Body;
	private static var line:Line;
	private static var player:Person;
	
	#if debug
	public var echo_debug_drawer:HeapsDebug;
	#end

	static function main() {
		Res.initEmbed();
		new Main();
	}

	// avatar game
	// run and walk
	// move character facing direction
	// mouse on left click, "aim". Only allow walking attack speeds.
	// character will face mouse direction
	// dodge on right
	override function init() {
		super.init();
		// Create a new echo World, set to the size of the heaps engine
		world = new World({
			width: s2d.width,
			height: s2d.height,
			gravity_y: 0
		});
		var body = new Body({
			x: 50,
			y: 50,
			elasticity: 0.3,
			shape: {
				type: RECT,
				width: 50,
				height: 50
			}
		});
		body.velocity.x = 10;
		world.add(body);

		loadCursor();
		loadTileMap();
		loadLine();
		
		#if debug
		echo_debug_drawer = new HeapsDebug(s2d);
		#end
	}

	override function onResize() {
		super.onResize();
		world.width = s2d.width;
		world.height = s2d.height;
	}

	private function loadTileMap() {
		var map = new ogmo.Project(Res.data.AvatarWorld_ogmo, true);
		var player:ogmo.Entity = null;
		var enemies:List<ogmo.Entity> = new List<ogmo.Entity>();
		for (level in map.levels) {
			for (layer in level.layers) {
				for (entity in layer.entities) {
					switch (entity.name) {
						case 'player':
							player = entity;
						case 'enemy':
							enemies.add(entity);
					}
				}
				layer.render(s2d);
			}
		}
		loadPlayer(player);
		loadLevelEnemies(enemies);
	}

	private function loadLevelEnemies(enemies:List<ogmo.Entity>) {
		for (entity in enemies) {
			loadEnemy(entity);
		}
	}

	private function loadEnemy(entity:ogmo.Entity) {
		// Need somewhere to store data.
		var enemy:PersonEnemy = new PersonEnemy(s2d, {
			x: entity.x,
			y: entity.y,
			drag_length: 20,
			elasticity: 0.2,
			shape: {
				type: CIRCLE,
				radius: 16,
			}
		});
		enemy.personAnimation();
	}

	private function loadPlayer(entity:ogmo.Entity) {
		//var player:Player = new Player(s2d);
		// Need somewhere to store data.
		player = PersonUtils.GetPerson(s2d, {
			x: entity.x,
			y: entity.y,
			drag_length: 20,
			elasticity: 0.2,
			shape: {
				type: CIRCLE,
				radius: 16,
			}
		}, "air");
		player.name = "player";
		// player.setPosition(entity.x, entity.y);
		player.personAnimation();
	}

	private function updateMousePlayer(dt:Float) {
		//line.start.set(player.body.x, player.body.y);
		// step cursor
		cursor.velocity.set(s2d.mouseX - cursor.x, s2d.mouseY - cursor.y);
		cursor.velocity *= 100;
		line.end.set(cursor.velocity.x, cursor.velocity.y);
		echo_debug_drawer.draw_line(line.start.x, line.start.y, line.end.x, line.end.y, echo_debug_drawer.intersection_color);
	}

	private function loadLine() {
		line = Line.get(world.width / 2, world.height / 2, world.width / 2, world.height / 2); 
		//Line.get(player.body.x, player.body.y);
	}

	private function loadCursor() {
		cursor = new Body({
			x: world.width * 0.5,
			y: world.height * 0.5,
			shape: {
				type: CIRCLE,
				radius: 16
			}
		});
		world.add(cursor);
	}

	override function update(dt:Float) {
		super.update(dt);
		updateMousePlayer(dt);
		// step all the entities
		for (entity in Entity.all)
			entity.step(dt);
		// step the world
		world.step(dt);
		#if debug
		// if (Key.isPressed(Key.QWERTY_TILDE) || Key.isPressed(Key.TAB))
		//	echo_debug_drawer.canvas.visible = !echo_debug_drawer.canvas.visible;
		echo_debug_drawer.draw(world);
		#end
	}
}
