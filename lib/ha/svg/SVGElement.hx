package lib.ha.svg;

import lib.ha.aggx.vectorial.LineCap;
import lib.ha.aggx.vectorial.LineJoin;
import lib.ha.core.geometry.AffineTransformer;
import lib.ha.aggx.color.RgbaColor;

class SVGElement
{
    public var index: UInt;
    public var fill_color: RgbaColor;
    public var stroke_color: RgbaColor;
    public var fill_flag: Bool;
    public var stroke_flag: Bool;
    public var even_odd_flag: Bool;
    public var line_join: Int; // ENUM CLASS
    public var line_cap: Int; // ENUM CLASS
    public var miter_limit: Float;
    public var stroke_width: Float;
    public var transform: AffineTransformer;
    public var id: String;
    public var gradientId: String;
    public var bounds: SVGPathBounds = new SVGPathBounds();

    private function new ()
    {
        index = 0;
        fill_color = new RgbaColor();
        stroke_color = new RgbaColor();
        fill_flag = true;
        stroke_flag = false;
        even_odd_flag = false;
        line_join = LineJoin.MITER;
        line_cap = LineCap.BUTT;
        miter_limit = 1.0;
        stroke_width = 1.0;
        transform = new AffineTransformer();
    }

    static public function create(): SVGElement
    {
        return new SVGElement();
    }

    static public function copy(attr: SVGElement, ?idx: UInt): SVGElement
    {
        var result: SVGElement = new SVGElement();
        result.index = idx != null ? idx : attr.index;
        result.fill_color.set(attr.fill_color);
        result.stroke_color.set(attr.stroke_color);
        result.fill_flag = attr.fill_flag;
        result.stroke_flag = attr.stroke_flag;
        result.even_odd_flag = attr.even_odd_flag;
        result.line_join = attr.line_join;
        result.line_cap = attr.line_cap;
        result.miter_limit = attr.miter_limit;
        result.stroke_width = attr.stroke_width;
        result.bounds = SVGPathBounds.clone(attr.bounds);
        result.transform = AffineTransformer.of(attr.transform);
        return result;
    }
}