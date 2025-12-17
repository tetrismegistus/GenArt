import java.util.HashSet;     import java.util.List;     import java.util.regex.Matcher;
import java.util.Arrays;                                 import java.util.regex.Pattern; 
char sp =  32; char dq =  34; char nm =  35; char lp =  40; char rp =  41; char ax = 42;
char pa =  43; char cm =  44; char mi =  45; char pd =  46; char sc =  59; char lt = 60;  
char ec =  61; char gt =  62; char lb =  91; char bs =  92; char rb =  93; char  c = 94;  
char  s = 115; char wc = 119; char lc = 123; char pi = 124; char rc = 125; char ex = 33;
String[] kw = {"Character","char","String", "float", 
"int","return","void","length","new",
"import","null","thelastindex","fill","textWidth",
"text","save","toString","textFont","createFont",
"size", "setup","background","if","while",
"else", "for"};
void setup() { String[] code = {
"import java.util.HashSet;     import java.util.List;     import java.util.regex.Matcher;",
"import java.util.Arrays;                                 import java.util.regex.Pattern;", 
"char sp =  32; char dq =  34; char nm =  35; char lp =  40; char rp =  41; char ax = 42;",
"char pa =  43; char cm =  44; char mi =  45; char pd =  46; char sc =  59; char lt = 60;",  
"char ec =  61; char gt =  62; char lb =  91; char bs =  92; char rb =  93; char  c = 94;",  
"char  s = 115; char wc = 119; char lc = 123; char pi = 124; char rc = 125; char ex = 33;", 
"String[] kw = {",
"};",
"void setup() { String[] code = {",
"  };",
"  textFont(createFont(code[code.length - 2], 14));",
"  size(910, 1602);background(#fffffe);",
"  for (int i = 0; i < 6; i++) { d(code[i], 20, 20 + 16 * i);}",
"  d( code[ 6]+dq+      kw[ 0]+dq+cm+dq+kw[ 1]+dq+cm+dq+kw[ 2]+dq+cm+dq+kw[ 3]+dq+cm,20,56+10*6  + 1);",
"  d(dq+kw[ 4]+dq+cm+dq+kw[ 5]+dq+cm+dq+kw[ 6]+dq+cm+dq+kw[ 7]+dq+cm+dq+kw[ 8]+dq+cm,20,64+10*7  + 1);",
"  d(dq+kw[ 9]+dq+cm+dq+kw[10]+dq+cm+dq+kw[11]+dq+cm+dq+kw[12]+dq+cm+dq+kw[13]+dq+cm,20,72+10*8  + 1);",
"  d(dq+kw[14]+dq+cm+dq+kw[15]+dq+cm+dq+kw[16]+dq+cm+dq+kw[17]+dq+cm+dq+kw[18]+dq+cm,20,80+10*9  + 1);",
"  d(dq+kw[19]+dq+cm+dq+kw[20]+dq+cm+dq+kw[21]+dq+cm+dq+kw[22]+dq+cm+dq+kw[23]+dq+cm,20,88+10*10 + 1);",
"  d(dq+kw[24]+dq+cm+dq+kw[25]+dq+code[7],20,96+10*11);",
"  for (int i =  8; i <               9; i++) { d(               code[i], 20,  96 + i * 16);}",
"  for (int i =  0; i < code.length    ; i++) { d(dq + code[i] + dq + cm, 20, 240 + i * 16);}",
"  for (int i =  9; i < code.length - 2; i++) { d(               code[i], 20, 864 + i * 16);}",
"  save(code[code.length - 1]);",
"}",
"String ts(char s) { return Character.toString(s); }",
"void d(String t, float sx, float sy) {",
"  HashSet<String> ow = new HashSet<String>(Arrays.asList(Arrays.copyOfRange(kw,  0,  5)));",
"  HashSet<String> rw = new HashSet<String>(Arrays.asList(Arrays.copyOfRange(kw,  5, 12)));",
"  HashSet<String> pw = new HashSet<String>(Arrays.asList(Arrays.copyOfRange(kw, 12, 22)));",
"  HashSet<String> bw = new HashSet<String>(Arrays.asList(Arrays.copyOfRange(kw, 22, 26)));",
"  float x = sx;float y = sy;",
"  Pattern pattern=Pattern.compile(ts(dq)+ts(lp)+ts(lb)+ts(c) +ts(dq)+ts(rb)+ts(ax)+ts(rp)",
"     +ts(dq)+ts(pi)+ts(lp)+ts(bs)+ts(wc)+ts(pa)+ts(rp)+ts(pi)+ts(lp)+ts(lb)+ts(bs)+ts(s)",
"     +ts(lt)+ts(gt)+ts(bs)+ts(lb)+ts(bs)+ts(rb)+ts(dq)+ts(cm)+ts(pd)+ts(sc)+ts(lp)+ts(rp)",
"     +ts(lc)+ts(rc)+ts(ec)+ts(pa)+ts(nm)+ts(bs)+ts(ex)+ts(ax)+ts(mi)+ts(rb)+ts(rp));",
"  Matcher mr = pattern.matcher(t);", 
"  while (mr.find()) { if (mr.group(1) != null) { fill(#0083cd);", 
"  String wd = dq + mr.group(1) + dq;  float wW = textWidth(wd);", 
"  text(wd, x, y); x += wW; }    else if (mr.group(2) != null) {",  
"  String wd = mr.group(2);if (ow.contains(wd)) { fill(#f89300);",
"  } else if (rw.contains(wd)) { fill(#d4006b); }  else if (pw.contains(wd)) {",
"  fill(#db86a1); } else if (bw.contains(wd)) { fill(#00b5f8);        } else {",
"  fill(#000000); } float wW = textWidth(wd); text(wd, x, y); x += wW;} else {", 
"  fill(#000000); String separator = mr.group(3); float wW = textWidth(separator);",
"  text(separator, x, y); x += wW; } }",
"}",
"SourceCodePro-Regular.ttf",
"quine_processing_4_3.png",
};
  textFont(createFont(code[code.length - 2], 14));
  size(910, 1602);background(#fffffe);
  for (int i = 0; i < 6; i++) { d(code[i], 20, 20 + 16 * i);}
  d( code[ 6]+dq+      kw[ 0]+dq+cm+dq+kw[ 1]+dq+cm+dq+kw[ 2]+dq+cm+dq+kw[ 3]+dq+cm,20,56+10*6  + 1);
  d(dq+kw[ 4]+dq+cm+dq+kw[ 5]+dq+cm+dq+kw[ 6]+dq+cm+dq+kw[ 7]+dq+cm+dq+kw[ 8]+dq+cm,20,64+10*7  + 1);
  d(dq+kw[ 9]+dq+cm+dq+kw[10]+dq+cm+dq+kw[11]+dq+cm+dq+kw[12]+dq+cm+dq+kw[13]+dq+cm,20,72+10*8  + 1);
  d(dq+kw[14]+dq+cm+dq+kw[15]+dq+cm+dq+kw[16]+dq+cm+dq+kw[17]+dq+cm+dq+kw[18]+dq+cm,20,80+10*9  + 1);
  d(dq+kw[19]+dq+cm+dq+kw[20]+dq+cm+dq+kw[21]+dq+cm+dq+kw[22]+dq+cm+dq+kw[23]+dq+cm,20,88+10*10 + 1);
  d(dq+kw[24]+dq+cm+dq+kw[25]+dq+code[7],20,96+10*11);
  for (int i =  8; i <               9; i++) { d(               code[i], 20,  96 + i * 16);}
  for (int i =  0; i < code.length    ; i++) { d(dq + code[i] + dq + cm, 20, 240 + i * 16);}
  for (int i =  9; i < code.length - 2; i++) { d(               code[i], 20, 864 + i * 16);} 
  save(code[code.length - 1]);
}
String ts(char s) { return Character.toString(s); }
void d(String t, float sx, float sy) {   
  HashSet<String> ow = new HashSet<String>(Arrays.asList(Arrays.copyOfRange(kw,  0,  5)));
  HashSet<String> rw = new HashSet<String>(Arrays.asList(Arrays.copyOfRange(kw,  5, 12)));
  HashSet<String> pw = new HashSet<String>(Arrays.asList(Arrays.copyOfRange(kw, 12, 22)));
  HashSet<String> bw = new HashSet<String>(Arrays.asList(Arrays.copyOfRange(kw, 22, 26)));
  float x = sx;float y = sy;
  Pattern pattern=Pattern.compile(ts(dq)+ts(lp)+ts(lb)+ts(c) +ts(dq)+ts(rb)+ts(ax)+ts(rp)
     +ts(dq)+ts(pi)+ts(lp)+ts(bs)+ts(wc)+ts(pa)+ts(rp)+ts(pi)+ts(lp)+ts(lb)+ts(bs)+ts(s)
     +ts(lt)+ts(gt)+ts(bs)+ts(lb)+ts(bs)+ts(rb)+ts(dq)+ts(cm)+ts(pd)+ts(sc)+ts(lp)+ts(rp)
     +ts(lc)+ts(rc)+ts(ec)+ts(pa)+ts(nm)+ts(bs)+ts(ex)+ts(ax)+ts(mi)+ts(rb)+ts(rp));
  Matcher mr = pattern.matcher(t); 
  while (mr.find()) { if (mr.group(1) != null) { fill(#0083cd); 
  String wd = dq + mr.group(1) + dq;  float wW = textWidth(wd); 
  text(wd, x, y); x += wW; }    else if (mr.group(2) != null) {  
  String wd = mr.group(2);if (ow.contains(wd)) { fill(#f89300);
  } else if (rw.contains(wd)) { fill(#d4006b); }  else if (pw.contains(wd)) {
  fill(#db86a1); } else if (bw.contains(wd)) { fill(#00b5f8);        } else {
  fill(#000000); } float wW = textWidth(wd); text(wd, x, y); x += wW;} else {  
  fill(#000000); String separator = mr.group(3); float wW = textWidth(separator);
  text(separator, x, y); x += wW; } }
}
