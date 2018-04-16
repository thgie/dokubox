package 
{
	import com.google.zxing.BarcodeFormat;
	import com.google.zxing.BinaryBitmap;
	import com.google.zxing.BufferedImageLuminanceSource;
	import com.google.zxing.DecodeHintType;
	import com.google.zxing.MultiFormatReader;
	import com.google.zxing.MultiFormatWriter;
	import com.google.zxing.Result;
	import com.google.zxing.client.result.ParsedResult;
	import com.google.zxing.client.result.ResultParser;
	import com.google.zxing.common.ByteMatrix;
	import com.google.zxing.common.GlobalHistogramBinarizer;
	import com.google.zxing.common.flexdatatypes.HashTable;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	
	/**
	 * ...
	 * @author FabianoPS
	 */
	public class QRUID extends Sprite 
	{
		
		private var video:Video
		private var camera:Camera
		private var rect:Rectangle;
		private var rectSize:int = 300;
		private var myReader:MultiFormatReader;
		private var bmd:BitmapData;
		private var debug:Bitmap;
		
		private var qrCallback:String
		private var qrErrorCb:String
		private var intervalPointer:uint;
		
		
		public function QRUID():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			/*ExternalInterface.addCallback("start", init);
			ExternalInterface.addCallback("stop", stop);*/
			var interval:int = 1500;
			myReader = new MultiFormatReader();
			
			camera = Camera.getCamera();
			camera.setMode(640, 480, 24, true);
			camera.setQuality(0, 100);
			
			video = new Video(640, 480);
			video.attachCamera(camera);
			addChild(video);
			
			video.width  = stage.stageWidth;
			video.height = stage.stageWidth / 4 * 3;
			/*video.scaleX = -1;
			video.x = stage.stageWidth;*/
			
			rect = new Rectangle(
				stage.stageWidth / 2 - rectSize / 2,
				stage.stageHeight / 2 - rectSize / 2,
				rectSize, rectSize);
			
			var r:Shape = new Shape();
			r.graphics.lineStyle(1, 0xf00, 0.25);
			r.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
			
			addChild(r);
			
			bmd = new BitmapData(video.width, video.height, false);
			
			debug = new Bitmap();
			addChild(debug);
			
			setTimeout(function():void {
				intervalPointer = setInterval(decodeSnapshot, interval);
			}, 1000);
		}
		
		public function decodeBitmapData(bmpd:BitmapData):void
		{
			var lsource:BufferedImageLuminanceSource = new BufferedImageLuminanceSource(bmpd);
			var bitmap:BinaryBitmap = new BinaryBitmap(new GlobalHistogramBinarizer(lsource));
			
			var ht:HashTable = new HashTable();
			ht.Add(DecodeHintType.POSSIBLE_FORMATS, BarcodeFormat.QR_CODE);
			ht.Add(DecodeHintType.TRY_HARDER, true);

			var res:Result = null;
			
			try {
				res = myReader.decode(bitmap,ht);
			} catch(e:Error) {
				trace(e)
			}
			
			if (res == null) {
				trace("<<No decoder could read the barcode>>")
			} else {
				var parsedResult:ParsedResult = ResultParser.parseResult(res);
				
				trace('boing');
				trace(parsedResult.getType());
				//ExternalInterface.call(qrCallback, parsedResult.getDisplayResult())
			}
		}
		private function decodeSnapshot():void
		{
			bmd.fillRect(bmd.rect, 0);
			bmd.draw(video, null, null, null, rect);
			decodeBitmapData(bmd);
		}
		
	}
	
}

