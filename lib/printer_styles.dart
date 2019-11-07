enum PrinterAlign {left, center, right}
enum PrinterAttribute {normal, bold, reverse, underline}

class TextSize{
  const TextSize._internal(this.value);
  final int value;
  static const size1 = TextSize._internal(1);
  static const size2 = TextSize._internal(2);
  static const size3 = TextSize._internal(3);
  static const size4 = TextSize._internal(4);
}

class LineFeed{
  const LineFeed._internal(this.value);
  final int value;
  static const feed1 = LineFeed._internal(1);
  static const feed2 = LineFeed._internal(2);
  static const feed3 = LineFeed._internal(3);
}

class PrinterStyles{
  const PrinterStyles({
    this.underline = false,
    this.attribute = PrinterAttribute.normal,
    this.align = PrinterAlign.left,
    this.size = TextSize.size1,
    this.feed = LineFeed.feed1
  });

  final bool underline;
  final PrinterAttribute attribute;
  final PrinterAlign align;
  final TextSize size;
  final LineFeed feed;
}