import hxmath.math.Vector2;
import hxd.Window;
import sys.ssl.Key;
import hxd.Event;
import h2d.Interactive;
import h2d.Graphics;
import hxd.Res;
import h2d.Tile;
import h2d.Object;
import h2d.Anim;
import h2d.Drawable;
import hxd.fmt.blend.Data.Handle;
import echo.data.Options.BodyOptions;

class Person extends Entity {
	var WALKSPEED:Float = 5000;
	var RUNSPEED:Float = 10000;
	var DODGESPEED:Float = 30000;
	var BENDINGSPEED:Float = 50000;

	var tile:Tile;
	var anim:Anim = new Anim();
	var atkIndex:Int = 0;
	var isAttacking:Bool = false;
	var isDodging:Bool = false;
	var isRunning:Bool = false;
	var gender:String = "m";
	var facing:String = "downleft";
	var speed:Float = 0;

	public var anims:Map<String, Array<Tile>> = new Map<String, Array<Tile>>();

	public override function new(?parent:Object, body_options:BodyOptions) {
		super(parent, body_options);
		this.anim = new Anim(null, 10, this);
		loadPersonData();
		parent.getScene().addEventListener(personEvent);
	}

	public function personAnimation() {
		var a:Array<Tile> = PersonUtils.animCal(this.tile, 64, 64, 64, this.facing);
		idleAnimation(a);
		// if ((this.x != 0 || this.x != 0)) {
		// 	if (isDodging) {
		// 		dodgeRollAnimation(a);
		// 	} else {
		// 		if (isRunning) {
		// 			runAnimation(a);
		// 		} else {
		// 			walkAnimation(a);
		// 		}
		// 	}
		// } else {
		// 	idleAnimation(a);
		// }
	}

	private function personEvent(event:Event) {
		if (event.kind != EKeyDown && event.kind != EKeyUp)
			return;
		var up = hxd.Key.isDown(hxd.Key.W);
		var down = hxd.Key.isDown(hxd.Key.S);
		var left = hxd.Key.isDown(hxd.Key.A);
		var right = hxd.Key.isDown(hxd.Key.D);
		isRunning = hxd.Key.isDown(hxd.Key.SHIFT);
		speed = personSpeedCal();
		if (up || down)
			body.velocity.x = 0;
		if (left || right)
			body.velocity.y = 0;

		if (up && down) {
			up = down = false;
		}
		if (left && right) {
			left = right = false;
		}
		if (up || down || left || right) {
			if (up) {
				this.facing = "up";
				if (left) {
					this.facing += "left";
				} else if (right) {
					this.facing += "right";
				}
			} else if (down) {
				this.facing = "down";
				if (left) {
					this.facing += "left";
				} else if (right) {
					this.facing += "right";
				}
			} else if (left) {
				this.facing = "left";
			} else if (right) {
				this.facing = "right";
			}

			this.personAnimation();
		}
	}

	private function movePerson(dt:Float) {
		var newAngle:Float = 0;
		switch (this.facing) {
			case "up":
				newAngle = 270;
			case "upleft":
				newAngle = 225;
			case "upright":
				newAngle = 315;
			case "down":
				newAngle = 90;
			case "downleft":
				newAngle = 135;
			case "downright":
				newAngle = 45;
			case "left":
				newAngle = 180;
			case "right":
				newAngle = 0;
		}
		var angle = hxd.Math.degToRad(newAngle);
		this.body.velocity.set(Math.cos(angle) * this.speed * dt, Math.sin(angle) * this.speed * dt);
		// if (up) this.body.velocity.y = -speed * dt;
		// if (down) this.body.velocity.y = speed * dt;
		// if (left) this.body.velocity.x = -speed * dt;
		// if (right) this.body.velocity.x = speed * dt;
		body.drag.x = body.drag.y = 1000 * 2;
	}

	private function personSpeedCal():Float {
		var playerSpeed:Float = WALKSPEED;
		if (isRunning) {
			playerSpeed = RUNSPEED;
		}
		if (isDodging) {
			playerSpeed = DODGESPEED;
		}
		return playerSpeed;
	}

	private function loadPersonData() {
		// for character setup, e.g. clothing, inventory etc.
	}

	private function walkAnimation(a:Array<Tile>) {
		this.anim.speed = 8;
		switch (facing) {
			case "up":
				this.anim.play([for (i in 7...14 + 1) a[i]]);
			case "down":
				this.anim.play([for (i in 39...46 + 1) a[i]]);
			case "left", "right":
				this.anim.play([for (i in 55...62 + 1) a[i]]);
			case "upleft", "upright":
				this.anim.play([for (i in 23...30 + 1) a[i]]);
			case "downleft", "downright":
				this.anim.play([for (i in 79...85 + 1) a[i]]);
		}
	}

	private function runAnimation(a:Array<Tile>) {
		switch (facing) {
			case "up":
				this.anim.play([for (i in 15...22 + 1) a[i]]);
			case "down":
				this.anim.play([for (i in 47...54 + 1) a[i]]);
			case "left", "right":
				this.anim.play([for (i in 71...77 + 1) a[i]]);
			case "upleft", "upright":
				this.anim.play([for (i in 31...38 + 1) a[i]]);
			case "downleft", "downright":
				this.anim.play([for (i in 63...70 + 1) a[i]]);
		}
	}

	private function dodgeRollAnimation(a:Array<Tile>) {
		switch (facing) {
			case "up":
				this.anim.play([for (i in 94...95 + 1) a[i]]);
			case "down":
				this.anim.play([for (i in 90...91 + 1) a[i]]);
			case "left", "right":
				this.anim.play([for (i in 88...89 + 1) a[i]]);
			case "upleft", "upright":
				this.anim.play([for (i in 92...93 + 1) a[i]]);
			case "downleft", "downright":
				this.anim.play([for (i in 86...87 + 1) a[i]]);
		}
	}

	private function idleAnimation(a:Array<Tile>) {
		this.anim.speed = 0.5;
		switch (facing) {
			case "up":
				this.anim.play([for (i in 94...95 + 1) a[i]]);
			case "down":
				this.anim.play([for (i in 90...91 + 1) a[i]]);
			case "left", "right":
				this.anim.play([for (i in 88...89 + 1) a[i]]);
			case "upleft", "upright":
				this.anim.play([for (i in 92...93 + 1) a[i]]);
			case "downleft", "downright":
				this.anim.play([for (i in 86...87 + 1) a[i]]);
		}
	}

	// Overide echo update loop
	public override function step(dt:Float) {
		super.step(dt);
		this.movePerson(dt);
	}
}
