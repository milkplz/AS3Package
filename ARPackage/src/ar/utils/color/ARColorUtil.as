﻿/** * AnotherRainbow * @author Zzanzza */package ar.utils.color {	import ar.utils.color.model.ARColorToneModel;		import flash.display.BitmapData;	import flash.filters.ColorMatrixFilter;	import flash.geom.Point;	import flash.geom.Rectangle;
		public class ARColorUtil {				private static const	MONOTONE_MIN	:uint = 150;		private static const	MONOTONE_MAX	:uint = 550;		private static const	LIMIT_WIDTH		:uint = 100;		private static const	LIMIT_HEIGHT	:uint = 100;				public	static const	COLOR_TONE_OF_RED	:String = "COLOR_TONE_OF_RED";		public	static const	COLOR_TONE_OF_BLUE	:String = "COLOR_TONE_OF_BLUE";		public	static const	COLOR_TONE_OF_GREEN	:String = "COLOR_TONE_OF_GREEN";		public	static const	COLOR_TONE_OF_MONO	:String = "COLOR_TONE_OF_MONO";		public function ARColorUtil() {	}				static public function getColorAverage($rect:Rectangle, $data:BitmapData):uint		{			var colour	:uint;			var red		:uint = 0;			var green	:uint = 0;			var blue	:uint = 0;			var div		:uint = $rect.width * $rect.height;					for (var i:uint = 0; i < $rect.width; i++) 			{				for (var j:uint = 0; j < $rect.height; j++)				{					colour = $data.getPixel($rect.x + i,$rect.y + j);					red += colour >> 16;					green += (colour >> 8) & 0xff;					blue += colour & 0x00ff;				}			}			return ((red/div) << 16) | ((green/div) << 8) | (blue/div);		}				static public function getBrightnessAverage($data:BitmapData):Number		{			var v:Vector.<Vector.<Number >  >  = $data.histogram();			var r:Number = 0;			var g:Number = 0;			var b:Number = 0;			var a:Number = 0;						for (var i:uint=0; i<256; i++) {				r +=  i * v[0][i] / 255;				g +=  i * v[1][i] / 255;				b +=  i * v[2][i] / 255;				a += i*v[3][i]/255;							}			var totalPixels:uint = $data.rect.width * $data.rect.height;			r /=  totalPixels;			g /=  totalPixels;			b /=  totalPixels;			a /= totalPixels;						var brightness:Number = (r+g+b)/3;			return brightness;		}				static public function getColorTone($rect:Rectangle, $data:BitmapData):ARColorToneModel		{			var colour	:uint = getColorAverage($rect, $data);			var R		:uint = colour >> 16;			var G		:uint = (colour >> 8) & 0xFF;			var B		:uint = colour & 0x00FF;			var total	:uint = R+G+B;						var big		:uint = new Array(R,G,B).sort( Array.NUMERIC | Array.DESCENDING )[0];						var colorTone	:String;						var average	:Number = total/3;			var gap		:Number = Math.abs(R-average) + Math.abs(G-average) + Math.abs(B-average);						if (total <= MONOTONE_MIN || total >= MONOTONE_MAX || gap < 10)				colorTone = COLOR_TONE_OF_MONO;			else if (big == R)				colorTone = COLOR_TONE_OF_RED;			else if (big == G)				colorTone = COLOR_TONE_OF_GREEN;			else //if (big == B)				colorTone = COLOR_TONE_OF_BLUE;							return new ARColorToneModel(colorTone, R, G, B);		}				public static function setMonoTone($bd:BitmapData):BitmapData		{			var _monoFilter:ColorMatrixFilter = new ColorMatrixFilter([	0.212671, 0.715160, 0.072169, 0, 0,																		0.212671, 0.715160, 0.072169, 0, 0,																		0.212671, 0.715160, 0.072169, 0, 0,																		0, 			     0,		   0, 1, 0 ]);						$bd.applyFilter($bd, new Rectangle(0,0,$bd.width,$bd.height), new Point(), _monoFilter);			return $bd;		}		public static function setThreeTone($bitmapData:BitmapData, $amountNum1:uint, $amountNum2:uint):BitmapData		{			var monobit:BitmapData = setMonoTone($bitmapData);			var bit:BitmapData = new BitmapData($bitmapData.width, $bitmapData.height, true, 0x000000);			var bit2:BitmapData = new BitmapData($bitmapData.width, $bitmapData.height, true, 0x000000);						bit.threshold(monobit.clone(), new Rectangle(0,0,bit.width, bit.height), new Point(), '<', 65793*$amountNum1, 0xFF7a7a7a, 0xff, false);			bit2.threshold(monobit.clone(), new Rectangle(0,0,bit.width, bit.height), new Point(), '<', 65793*$amountNum2, 0xFF000000, 0xff, false);			bit.merge(bit2, new Rectangle(0,0,bit.width,bit.height), new Point(), 0xFF, 0xFF, 0xFF, 0x50);			monobit.dispose();			bit2.dispose();			$bitmapData.dispose();			return bit;		}		public static function autoThreeTone($bitmapData:BitmapData, $colorAverage:uint):BitmapData		{			var monobit:BitmapData = setMonoTone($bitmapData);			var bit:BitmapData = new BitmapData($bitmapData.width, $bitmapData.height, true, 0x000000);			var bit2:BitmapData = new BitmapData($bitmapData.width, $bitmapData.height, true, 0x000000);			var n1:Number, n2:Number;						if(uint($colorAverage/100000) >= 150){				n2 = 200;				n1 = n2+15;			}else{				n2 = uint($colorAverage/100000)+10;				n1 = n2+30;			}						bit.threshold(monobit.clone(), new Rectangle(0,0,bit.width, bit.height), new Point(), '<', n1, 0xFF7a7a7a, 0xff, false);			bit2.threshold(monobit.clone(), new Rectangle(0,0,bit.width, bit.height), new Point(), '<', n2, 0xFF000000, 0xff, false);			bit.merge(bit2, new Rectangle(0,0,bit.width,bit.height), new Point(), 0xFF, 0xFF, 0xFF, 0x50);			monobit.dispose();			bit2.dispose();			$bitmapData.dispose();			return bit;		}	}}