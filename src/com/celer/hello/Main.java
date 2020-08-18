package com.celer.hello;

import android.os.Bundle;
import android.app.Activity;
import android.graphics.Color;
import android.view.*;
import android.widget.*;

// A "Hello World" activity
public final class Main extends Activity{

   @Override
   public final void onCreate(Bundle bb){
      super.onCreate(bb);

      // Create a simple vertical layout, add an image and a static text:
      LinearLayout vertLayOut = new LinearLayout(this);
      vertLayOut.setOrientation(LinearLayout.VERTICAL);
      vertLayOut.setGravity(Gravity.CENTER_HORIZONTAL);
      vertLayOut.setBackgroundColor(Color.BLACK);
      vertLayOut.setLayoutParams(
         new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.FILL_PARENT,
            ViewGroup.LayoutParams.FILL_PARENT
         )
      );
      ImageView logo = new ImageView(this);
      logo.setPadding(20, 20, 20, 20);
      logo.setImageResource(R.mipmap.icon);
      vertLayOut.addView(logo);
      TextView txt = new TextView(this);
      txt.setPadding(20, 20, 20, 20);
      txt.setTextColor(Color.WHITE);
      txt.setText("Hello World!");
      txt.setGravity(Gravity.CENTER_HORIZONTAL);
      vertLayOut.addView(txt);
      setContentView(vertLayOut);
   }
}
