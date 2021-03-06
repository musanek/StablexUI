package ru.stablex.ui.widgets;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.Point;
import ru.stablex.Err;


/**
* Simple Bitmap. Bitmap is drawn using .graphics.beginBitmapFill()
*/

class Bmp extends Widget{
    //Asset ID or path to bitmap
    public var src (get_src,set_src): String;
    @:noCompletion public var _src : String = null;
    //Should we use smoothing?
    public var smooth : Bool = true;
    /** keep aspect ratio */
    public var keepAspect : Bool = false;    
    //set size depending on bitmap size
    public var autoSize (never,set_autoSize) : Bool;
    //set width depending on bitmap width
    public var autoWidth : Bool = true;
    //set height depending on bitmap height
    public var autoHeight : Bool = true;
    /**
    * Use this property instead of `.src`, if you need to directly assign BitmapData instance.
    * `.bitmapData` will be set to null automatically, if you set `.src`.
    * `.src` will be set to null automatically, if you set `.bitmapData`
    */
    public var bitmapData (get_bitmapData,set_bitmapData) : BitmapData;
    @:noCompletion private var _bitmapData : BitmapData = null;
    /**
    * If you want to draw just a portion of the bitmap. Specify top/left corner of
    * desired source rectangle by `.xOffset` and `.yOffset` and widht/height for
    * that rectangle will be taken from `.w` and `.h` of this widget. If `.autoSize` is true,
    * width and height will be taken from `.xOffset` and `.yOffset` to bitmap right border
    * and bottom border respectively
    */
    public var xOffset (default, set_xOffset) = 0.0;
    // y offset for drawing a portion of the bitmap
    public var yOffset (default, set_yOffset) = 0.0;
    /**
    * When `.xOffset` or `.yOffset` is set, this property is changed to true.
    * To draw full image on next refresh set this property to false again.
    */
    public var drawPortion : Bool = false;

/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/

/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/

    /**
    * Refresh widget. Draw bitmap on this.graphics
    *
    * @throw <type>String</type> if asset for bitmap was not found
    */
    override public function refresh() : Void {
        var bmp : BitmapData = this._bitmapData;

        if( bmp == null && this.src != null ){
            bmp = Assets.getBitmapData(this.src);
            if( bmp == null ){
                Err.trigger('Bitmap not found: ' + this.src);
            }
        }

        if( bmp != null ){
            var w = this.drawPortion? bmp.width - this.xOffset : bmp.width;
            var h = this.drawPortion? bmp.height - this.yOffset : bmp.height;
            //handle auto size
            if (this.autoWidth && this.autoHeight && (this._width != w  || this._height != h)) {
                this.resize(bmp.width, bmp.height);
            } else if (this.autoWidth && this._width != w) {
                this.w = w;
            } else if(this.autoHeight && this._height != h) {
                this.h = h;
            }

            super.refresh();
            this._draw(bmp);
        }else{
            super.refresh();
        }
    }//function refresh()



    /**
    * Draw bitmapdata specified by this.src
    *
    * @throw <type>String</type> if asset for bitmap was not found
    */
    private inline function _draw(bmp:BitmapData) {
        this.graphics.clear();

        var mx : Matrix = new Matrix();
        var width = bmp.width;
        var height = bmp.height;

        //draw just part of image
        if( this.drawPortion ){
            width -= Std.int(this.xOffset);
            height -= Std.int(this.yOffset);

            //draw zero?
            if( width > 0 && height > 0 ){
                #if html5
                    var dest = new BitmapData(Std.int(width), Std.int(height));
                    dest.copyPixels(bmp, new Rectangle(this.xOffset, this.yOffset, width, height), new Point(0, 0));
                    bmp = dest;                
                #else
                    mx.translate(-this.xOffset, -this.yOffset);
                #end
            }
        }

        if( width > 0 && height > 0 ) {
            // this.graphics.beginBitmapFill(bmp, null, false, this.smooth);
            // this.graphics.drawRect(0, 0, bmp.width, bmp.height);
            // this.graphics.endFill();

            //if autoSizing, this will be 1 so it is ok keep it simple
            var scaleX = this.w / width;
            var scaleY = this.h / height;            

            if (keepAspect) {
                var scale : Float = Math.min(scaleX, scaleY);
                mx.scale(scale, scale);
            } else { //distort
                mx.scale(scaleX, scaleY);
            }

            this.graphics.beginBitmapFill(bmp, mx, false, this.smooth);
            this.graphics.drawRect(0, 0, width * mx.a, height * mx.d);
            this.graphics.endFill();
        }

        

    }//function _draw()


/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/


    /**
    * Getter src
    *
    */
    private inline function get_src() : String {
        return this._src;
    }//function get_src()


    /**
    * Setter src
    *
    */
    private inline function set_src(src:String) : String {
        if( src != null ){
            this._bitmapData = null;
        }
        return this._src = src;
    }//function set_src()


    /**
    * Getter bitmapData
    *
    */
    private inline function get_bitmapData() : BitmapData {
        return this._bitmapData;
    }//function get_bitmapData()


    /**
    * Setter bitmapData
    *
    */
    private inline function set_bitmapData(bitmapData:BitmapData) : BitmapData {
        if( bitmapData != null ){
            this._src = null;
        }
        return this._bitmapData = bitmapData;
    }//function set_bitmapData()


    /**
    * Setter for autoSize
    *
    */
    @:noCompletion private function set_autoSize (as:Bool) : Bool {
        return this.autoWidth = this.autoHeight = as;
    }//function set_autoSize()


    /**
    * Setter for autoSize
    *
    */
    @:noCompletion private function set_xOffset (x:Float) : Float {
        this.drawPortion = true;
        return this.xOffset = (x >= 0 ? x : 0);
    }//function set_xOffset()

    /**
    * Setter for autoSize
    *
    */
    @:noCompletion private function set_yOffset (y:Float) : Float {
        this.drawPortion = true;
        return this.yOffset = (y >= 0 ? y : 0);
    }//function set_yOffset()

    /**
    * If width is set, disable autoWidth
    *
    */
    @:noCompletion override private function set_w(w:Float) : Float {
        this.autoWidth = false;
        return super.set_w(w);
    }//function set_w()


    /**
    * If width is set, disable autoWidth
    *
    */
    @:noCompletion override private function set_widthPt(wp:Float) : Float {
        this.autoWidth = false;
        return super.set_widthPt(wp);
    }//function set_widthPt()


    /**
    * If height is set, disable autoHeight
    *
    */
    @:noCompletion override private function set_heightPt(hp:Float) : Float {
        this.autoHeight = false;
        return super.set_heightPt(hp);
    }//function set_heightPt()


    /**
    * If height is set, disable autoHeight
    *
    */
    override function set_h(h:Float) : Float {
        this.autoHeight = false;
        return super.set_h(h);
    }//function set_h()

}//class Bmp