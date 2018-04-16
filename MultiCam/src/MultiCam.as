package
{
	import com.quietless.bitmap.BitmapSnapshot;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.text.TextField;
	
	public class MultiCam extends Sprite
	{
		// nice graphics & setuptext
		public var le_button:Sprite = new Sprite();
		public var setup_text:TextField = new TextField();
		
		// cameras meta information
		public var camera_count:int = 0;
		public var current_camera:int = 0;
		public var available_cameras:Array = new Array();
		public var cameras:Array = new Array();
		public var masks:Array = new Array();
		
		// get that stage size by half and quarter
		public var _wf:Number;
		public var _hf:Number;
		
		public var _wh:Number;
		public var _hh:Number;
		
		public var _wq:Number;
		public var _hq:Number;
		
		// project information
		public var uid:String = '';
		
		// get the fucker started
		public function MultiCam()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_wf = stage.stageWidth;
			_hf = stage.stageHeight;
			
			_wh = stage.stageWidth / 2;
			_hh = stage.stageHeight / 2;
			
			_wq = stage.stageWidth / 4;
			_hq = stage.stageHeight / 4;

			// a beautiful button it is
			var size:int = 140;
			var halfSize:uint = Math.round(size / 2);
			
			le_button.graphics.beginFill(0x2ecc71);
			le_button.graphics.drawCircle(halfSize, halfSize, halfSize);
			le_button.graphics.endFill();
			
			le_button.addEventListener(MouseEvent.CLICK, mouse_capture);
			
			setup_routine();
		}
		
		public function setup_routine():void
		{
			setup_text.width = 300;
			setup_text.height = 400;
			setup_text.y = _hh - setup_text.height / 2;
			setup_text.x = _wh - setup_text.width / 2;
			setup_text.selectable = false;
			
			addChild(setup_text);
			
			for(var c:int = 0; c < Camera.names.length; c++){
				var ac:Array = new Array();
				
				ac.push(c.toString());
				ac.push(Camera.names[c]);
				ac.push('on');
				
				available_cameras.push(ac);
			}
			
			addEventListener(KeyboardEvent.KEY_UP, setup_input);
			setup_output();
		}
		
		public function setup_input(e:KeyboardEvent):void
		{
			var target_cam:int = -1;
			
			switch(e.keyCode){
				case 48:
					target_cam = 0;
					break;
				case 49:
					target_cam = 1;
					break;
				case 50:
					target_cam = 2;
					break;
				case 51:
					target_cam = 3;
					break;
				case 52:
					target_cam = 4;
					break;
				
				case 13:
					grab_cameras();
					removeEventListener(KeyboardEvent.KEY_UP, setup_input);
					break;
			}
			
			if(target_cam < available_cameras.length && target_cam > -1) {
				if(available_cameras[target_cam][2] == 'on'){
					available_cameras[target_cam][2] = 'off';
				} else {
					available_cameras[target_cam][2] = 'on';
				}
			}
			
			setup_output();
		}
		
		public function setup_output():void
		{
			setup_text.text = '';
			
			for(var c:int = 0; c < available_cameras.length; c++) {
				setup_text.appendText(
					'['+available_cameras[c][0]+']: '
					+'('+available_cameras[c][2]+')\t'
					+available_cameras[c][1]+':\n'
				);
			}
			
			setup_text.appendText('\n\n[Enter]: Start Cameras');
		}
		
		public function grab_cameras():void
		{
			for(var ac:int = 0; ac < available_cameras.length; ac++){
				if(available_cameras[ac][2] == 'on'){
					camera_count++;
				}
			}
			
			for(var c:int = 0; c < available_cameras.length; c++){
				
				if(available_cameras[c][2] == 'off'){
					continue;
				}
				
				// grab that camera
				var camera_name:String = Camera.names[c];
				var camera:Camera = Camera.getCamera(c.toString());
				
				var quality_x:int = 0;
				var quality_y:int = 0;
				
				switch(camera_count){
					case 1:
						quality_x = 1280;
						quality_y = 960;
						break;
					case 2:
						quality_x = 640;
						quality_y = 480;
						break;
					case 3:
						quality_x = 320;
						quality_y = 240;
						break;
					case 4:
						quality_x = 320;
						quality_y = 240;
						break;
					default:
						trace("fucked up");
				}
				
				camera.setMode(quality_x, quality_y, 20);
				camera.setQuality(0, 100);
				
				if (camera != null) {
					var video:Video = new Video(320, 240);
					video.attachCamera(camera);
					video.smoothing = true;
					
					// mirror for right display on screen
					// video.scaleX = -1;
					
					var all_hell_is_lose:Array = new Array();
					
					all_hell_is_lose.push(camera_name);
					all_hell_is_lose.push(video);
					
					cameras.push(all_hell_is_lose);
					addChild(video);
				} else {
					trace("You need a camera.");
				}
			}
			
			layout();
		}
		
		// layout the cameras (and the beautiful button)
		public function layout():void
		{
			removeChild(setup_text);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyboard_capture);
			
			if(camera_count == 1){
				le_button.x = _wf - le_button.width - 20;
				le_button.y = 20;
			} else {
				le_button.x = _wh - le_button.width / 2;
				le_button.y = _hh - le_button.height / 2;
			}
			
			addChild(le_button);
			masks.length = 0;
			
			for(var m:int = 0; m < camera_count; m++){
				var mask:Shape = new Shape();
				addChild(mask);
				masks.push(mask);
			}
			
			switch(camera_count) {
				case 1:
					cameras[0][1].width = _wf;
					cameras[0][1].height = _wf / 4 * 3;
					break;
				case 2:
					cameras[0][1].width = _wf;
					cameras[0][1].height = _wf / 4 * 3;
					cameras[0][1].y = 0 - _hq;
					
					cameras[1][1].width = _wf;
					cameras[1][1].height = _wf / 4 * 3;
					cameras[1][1].y = _hh - _hq;
					
					cameras[0][1].mask = masks[0];
					masks[0].graphics.beginFill(0x00ff00);
					masks[0].graphics.drawRect(0, 0, _wf, _hh);
					masks[0].graphics.endFill();
					
					cameras[1][1].mask = masks[1];
					masks[1].graphics.beginFill(0x0000ff);
					masks[1].graphics.drawRect(0, _hh, _wf, _hh);
					masks[1].graphics.endFill();
					break;
				case 3:
					cameras[0][1].width = _hf / 3 * 4;
					cameras[0][1].height = _hf;
					cameras[0][1].x = 0 - _wq;
					
					cameras[1][1].width = _wh;
					cameras[1][1].height = _wh / 4 * 3;
					cameras[1][1].x = _wh;
					
					cameras[2][1].width = _wh;
					cameras[2][1].height = _wh / 4 * 3;
					cameras[2][1].x = _wh;
					cameras[2][1].y = _hh;
					
					cameras[0][1].mask = masks[0];
					masks[0].graphics.beginFill(0x00ff00);
					masks[0].graphics.drawRect(0, 0, _wh, _hf);
					masks[0].graphics.endFill();
					
					cameras[1][1].mask = masks[1];
					masks[1].graphics.beginFill(0x0000ff);
					masks[1].graphics.drawRect(_wh, 0, _wh, _hh);
					masks[1].graphics.endFill();
					
					cameras[2][1].mask = masks[2];
					masks[2].graphics.beginFill(0x0000ff);
					masks[2].graphics.drawRect(_wh, _hh, _wh, _hh);
					masks[2].graphics.endFill();
					break;
				case 4:
					for(var c:int = 0; c < camera_count; c++){
						
						var _x:Number = (c) % 2 * _wh;
						var _y:Number = 0;
						
						if(c > 1){
							_y += _hh;
						}
						
						cameras[c][1].width = _wh;
						cameras[c][1].height = _wh / 4 * 3;
						cameras[c][1].x = _x;
						cameras[c][1].y = _y;
						
						cameras[c][1].mask = masks[c];
						masks[c].graphics.beginFill(0x0000ff);
						masks[c].graphics.drawRect(_x, _y, _wh, _hh);
						masks[c].graphics.endFill();
					}
					break;
				default:
					trace("fucked up");
			}
		}
		
		public function keyboard_capture(e:KeyboardEvent):void
		{
			if(e.keyCode == 67){
				start_capture();
			}
		}
		
		public function mouse_capture(e:MouseEvent):void
		{
			start_capture();
		}
		
		public function start_capture():void
		{
			if(uid == ''){
				uid = get_uid();
			}
			
			var img:BitmapSnapshot = new BitmapSnapshot(this.stage, 'screenshot.jpg', stage.stageWidth, stage.stageHeight);
			img.saveOnServer('/upload', uid);
		}
		
		public function get_uid(value:Array = null):String {
			
			var uid:Array = new Array();
			var chars:Array = new Array( 48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70 );
			var separator:uint = 45;
			var template:Array = value || new Array( 8,4,4,4,12 );
			
			for ( var a:uint = 0; a < template.length; a++ ) {
				for ( var b:uint = 0; b < template[a]; b++ ) {
					uid.push( chars[ Math.floor( Math.random() *  chars. length ) ] );
				} if ( a < template.length - 1 ) {
					uid.push( separator ); 
				}
			}
			
			return String.fromCharCode.apply( null, uid );
		}
	}
}