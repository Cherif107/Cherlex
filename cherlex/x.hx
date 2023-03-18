function makeFullFrame(Radius:Int, Color:Int, Frames:Int, Shape:FlxPieDialShape, Clockwise:Bool, InnerRadius:Int):FlxSprite {
	var W = Radius * 2;
	var H = Radius * 2;

	var fullFrame = new FlxSprite().makeGraphic(W, H, FlxColor.TRANSPARENT, true);
	if (InnerRadius > Radius) {
		InnerRadius = 0;
	}

	var dR = Radius - InnerRadius;

	if (Shape == SQUARE) {
		fullFrame.pixels.fillRect(fullFrame.pixels.rect, Color);
		if (InnerRadius > 0) {
			_flashRect.setTo(dR, dR, InnerRadius * 2, InnerRadius * 2);
			fullFrame.pixels.fillRect(_flashRect, FlxColor.TRANSPARENT);
		}
	} else if (Shape == CIRCLE) {
		if (InnerRadius > 0) {
			var alpha = new BitmapData(fullFrame.pixels.width, fullFrame.pixels.height, false, FlxColor.BLACK);
			fullFrame.pixels.fillRect(_flashRect, FlxColor.BLACK);
			fullFrame.drawCircle(-1, -1, Radius, FlxColor.WHITE, null, {smoothing: true});
			fullFrame.drawCircle(-1, -1, InnerRadius, FlxColor.BLACK, null, {smoothing: true});

			alpha.copyPixels(fullFrame.pixels, fullFrame.pixels.rect, _flashPointZero, null, null, true);

			fullFrame.pixels.fillRect(fullFrame.pixels.rect, Color);
			fullFrame.pixels.copyChannel(alpha, alpha.rect, _flashPointZero, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);

			alpha.dispose();
		} else {
			fullFrame.drawCircle(-1, -1, Radius, Color);
		}
	} else if (Shape == HEART) {
		FlxSpriteUtil.beginDraw(Color);
		var centerX:Float = Radius;
		var centerY:Float = Radius - Radius / 4;
		var leftCurveX:Float = centerX - Radius / 2;
		var leftCurveY:Float = centerY - Radius / 2;
		var rightCurveX:Float = centerX + Radius / 2;
		var rightCurveY:Float = centerY - Radius / 2;
		FlxSpriteUtil.drawCurve(fullFrame, leftCurveX, leftCurveY, centerX, centerY, rightCurveX, rightCurveY, 4, FlxColor.TRANSPARENT, true);
		FlxSpriteUtil.drawCurve(fullFrame, leftCurveX, leftCurveY, centerX, centerY, rightCurveX, rightCurveY, 4, FlxColor.TRANSPARENT, false);
		FlxSpriteUtil.endDraw(fullFrame);

		if (InnerRadius > 0) {
			_flashRect.setTo(dR, dR, InnerRadius * 2, InnerRadius * 2);
			fullFrame.pixels.fillRect(_flashRect, FlxColor.TRANSPARENT);
		}
	}

	return fullFrame;
}