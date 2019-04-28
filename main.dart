import 'dart:html';
import 'aimweb.dart';
import 'dart:math';

MyGame game;
Point desiredSize=Point(800.0,1280.0);
double scaledX=0.0;
double scaledY=0.0;
Random rnd=new Random();
int score=0;
CanvasElement canv=querySelector("#output");
DivElement view=querySelector("#canGame");
CanvasRenderingContext2D ctx=canv.getContext('2d');

void main() {
  game=new MyGame(); 
  game.assets={
    "Panda": "images/panda.png",
    "PandaArms": "images/armsIdle.png",
    "PandaArmL": "images/leftArmJump.png",
    "PandaArmR": "images/rightArmJump.png",
    "PandaEyesL1": "images/leftEyesIdle.png",
    "PandaEyesL2": "images/leftEyesJump.png",
    "PandaEyesR1": "images/rightEyesIdle.png",
    "PandaEyesR2": "images/rightEyesJump.png",
    "PandaFootL1": "images/leftFootIdle.png",
    "PandaFootL2": "images/leftFootJump.png",
    "PandaFootR1": "images/rightFootIdle.png",
    "PandaFootR2": "images/rightFootJump.png",
    "Sea": "images/Sea.png",
    "Sea1": "images/Sea1.png",
    "Sea2": "images/Sea2.png",
    "Cloud1": "images/Cloud1.png",
    "Cloud2": "images/Cloud2.png",
    "Hill1": "images/Hill1.png",
    "Hill2": "images/Hill2.png",
    "Hill3": "images/Hill3.png",
    "Tree": "images/Tree.png",
    "Meat": "images/Meat.png",
    "Pizza": "images/Pizza.png"
  };
  game.loadAssets();
  
  game.fetchDone.listen((data){
    game.loadCompleted();
    }, 
    onError: (err){
    },
    onDone: (){
    },
    cancelOnError: false);

    window.animationFrame.then(game.realUpdate);
  window.onResize.listen((onData){
    resize();
  });
  
  resize();
}

void resize() {
  num ratio=desiredSize.x/desiredSize.y;
  num w,h;
  if (window.innerWidth / window.innerHeight >= ratio) {
    w = window.innerHeight * ratio;
    h = window.innerHeight;
  } else {
    w = window.innerWidth;
    h = window.innerWidth / ratio;
  }
  view.style.width = w.toString() + 'px';
  view.style.height = h .toString()+ 'px';
  canv.style.width = w.toString() + 'px';
  canv.style.height = h .toString()+ 'px';
  game.stage.scaleX=w/desiredSize.x;
  game.stage.scaleY=h/desiredSize.y;
}

class MyGame extends Game {
  Panda panda;
  double minY=800.0;
  int jumpC=0;
  int currentTree=3;
  Collector stagePanda;
  Collector stageTrees;
  Collector stageFruits;
  List<TreePiece> trees=new List<TreePiece>();
  List<Candy> candys=new List<Candy>();
  List<Pizza> pizzas=new List<Pizza>();
  Meat meat;
  List<Wave> seas=new List<Wave>();
  List<Hill1> hills1=new List<Hill1>();
  List<Sprite> hills=new List<Sprite>();
  List<Tree> treesB=new List<Tree>();

  void loadCompleted(){
    jumpC=1;

    stagePanda=new Collector();
    this.stage.addChild(stagePanda,this);

    for(int i=0; i<40;i++){
      if(i<10){
      var cl;
      if(i%2==0)
      cl=new Cloud1();
      else
      cl=new Cloud2();
      cl.init(rnd.nextDouble()*800, rnd.nextDouble()*500);
      }
      else
      if(i<20){
      var hi;
      if(i%2==0){
      hi=new Hill2();
      hi.init(-150+(i-10)*500-rnd.nextDouble()*300, 750+rnd.nextDouble()*200, i-10==0? 9 : i-11);
      hills.add(hi);
      }
      else {
      hi=new Hill3();
      hi.init(-150+(i-10)*500-rnd.nextDouble()*300, 750+rnd.nextDouble()*110, i-10==0? 9 : i-11);
      hills.add(hi);
      }
      }
      else
      if(i<30){
      var tr;
      tr=new Tree();
      tr.init(-150+(i-20)*330-rnd.nextDouble()*200, 750+rnd.nextDouble()*70, i-20==0? 9 : i-21);
      treesB.add(tr);
      }
      else
      if(i<40){
      var hh;
      hh=Hill1();
      hh.init(-333+(i-30)*900-rnd.nextDouble()*200, 750+rnd.nextDouble()*40, i-30==0? 9 : i-31);
      hills1.add(hh);
      }
    }

    var tr=new Terrain();
    tr.init();

    stageTrees=new Collector();
    this.stage.addChild(stageTrees,this);

    stageFruits=new Collector();
    this.stage.addChild(stageFruits,this);

    var sea2=new Wave();
    sea2.init(-215.0, 900.0, 2);
    seas.add(sea2);

    panda=new Panda();
    panda.init();

    var tree7=new TreePiece();
    tree7.init(-120.0);

    var tree1=new TreePiece();
    tree1.init(60.0);
    
    var tree2=new TreePiece();
    tree2.init(240.0);

    var tree3=new TreePiece();
    tree3.init(420.0);

    var tree4=new TreePiece();
    tree4.init(600.0);

    var tree5=new TreePiece();
    tree5.init(780.0);

    print("Y2");

    var tree=new TreePiece();
    tree.init(960.0);

    print("Y");

    var sea1=new Wave();
    sea1.init(-200.0, 1000.0, 1);
    seas.add(sea1);

    print("Y1");

    var sea3=new Wave();
    sea3.init(-220.0, 1100.0, 0);
    seas.add(sea3);

    canv.onMouseUp.listen((onData){
      var det=Point(onData.screen.x, onData.screen.y);
      print(det);
      this.onTapUp(det);
    });
  }

  void onTapUp(Point details){
    if(jumpC==1 && trees.length>3){
      if(panda.y-55<trees[currentTree].y && panda.y>40){
      panda.weight-=0.02;
      if(panda.weight<0.625)
      panda.weight=0.625;

      panda.scaleX=panda.weight;

      panda.scaleY=panda.weight/1.66;

      if(panda.scaleY<1)
      panda.scaleY=1.0;
      
      jumpC=2;
      panda.fallSp=-9.0;
      }
    }
  }

  @override
  void paint(CanvasRenderingContext2D canvas){
    super.paint(canvas);
  }


  void realUpdate(timestamp){
    this.update();
    this.paint(ctx);
    
    /*if(!timeCon){
        timeCon=timestamp;
        update();
    }
    else {
        deltaTime=timestamp-timeCon;
        deltaCon+=deltaTime*30;
        if(deltaCon>1000){
            deltaCon=deltaCon%1000;
            update();
        }
    }
    
    timeCon=timestamp;*/
    window.animationFrame.then(this.realUpdate);
  }

  @override
  void update(){
    super.update();

    if(seas.length>0){
      seas.forEach((Wave ww){
        ww.update();
      });
    }
  }
}

class PandaEyesL extends Sprite {
  PandaEyesL():super(game.images['PandaEyesL1'],Point(-53.0,-73.0));
}
class PandaEyesR extends Sprite {
  PandaEyesR():super(game.images['PandaEyesR1'],Point(-53.0,-73.0));
}
class PandaArmL extends Sprite {
  PandaArmL():super(game.images['PandaArmL'],Point(-53.0,-73.0));
}
class PandaArmR extends Sprite {
  PandaArmR():super(game.images['PandaArmR'],Point(-53.0,-73.0));
}
class PandaFootL extends Sprite {
  PandaFootL():super(game.images['PandaFootL1'],Point(-53.0,-73.0));
}
class PandaFootR extends Sprite {
  PandaFootR():super(game.images['PandaFootR1'],Point(-53.0,-73.0));
}

class PandaArms extends Sprite {
  PandaArms():super(game.images['PandaArms'],Point(-53.0,-73.0));
}

class Panda extends Sprite {
  double fallSp=1.0;
  double weight=1.0;
  double xx=420.0;
  PandaEyesL pandaEL;
  PandaEyesR pandaER;
  PandaArmL pandaAL;
  PandaArmR pandaAR;
  PandaFootL pandaFL;
  PandaFootR pandaFR;
  PandaArms pandaA;
  
  Panda():super(game.images['Panda'],Point(-53.0,-73.0));

  void init(){
    this.x=420.0;
    this.y=100.0;
    game.stagePanda.addChild(this, game);

    pandaEL=new PandaEyesL();
    pandaEL.x=420.0;
    pandaEL.y=100.0;
    game.stagePanda.addChild(pandaEL, game);

    pandaER=new PandaEyesR();
    pandaER.x=420.0;
    pandaER.y=100.0;
    game.stagePanda.addChild(pandaER, game);

    pandaFL=new PandaFootL();
    pandaFL.x=420.0;
    pandaFL.y=100.0;
    game.stagePanda.addChild(pandaFL, game);

    pandaFR=new PandaFootR();
    pandaFR.x=420.0;
    pandaFR.y=100.0;
    game.stagePanda.addChild(pandaFR, game);

    pandaAL=new PandaArmL();
    pandaAL.x=420.0;
    pandaAL.y=100.0;
    pandaAL.visible=false;
    game.stagePanda.addChild(pandaAL, game);

    pandaAR=new PandaArmR();
    pandaAR.x=420.0;
    pandaAR.y=100.0;
    pandaAR.visible=false;
    game.stagePanda.addChild(pandaAR, game);

    pandaA=new PandaArms();
    pandaA.x=420.0;
    pandaA.y=100.0;
    game.stageFruits.addChild(pandaA, game);
  }

  @override
  void update(){
    if(game.jumpC==1){
    fallSp+=0.17*(weight);
    this.x=420.0+game.trees[game.currentTree].shake*((game.trees[game.currentTree].y-this.y)/game.trees[game.currentTree].y);
    this.y+=fallSp;
    }
    else
    if(game.jumpC==2){
      fallSp+=0.17*weight;
      this.y+=fallSp;

      if(game.currentTree<3){
      this.x+=12*(0.5/weight);

      if(this.x>this.xx+180 && this.y-60<game.trees[game.currentTree].y){
        this.x=this.xx+180;
        this.xx=this.x;
        game.jumpC=1;
        this.fallSp=0.0;
        game.currentTree+=1;
      }
      }
    }

    if(this.scaleX<=1){
      pandaEL.x=pandaFL.x=this.x-1.5;
      pandaER.x=pandaFR.x=this.x+1.5;
      pandaAL.x=this.x-1.5+(1-this.scaleX)*40;
      pandaAR.x=this.x+1.5-(1-this.scaleX)*40;
    }
    else {
      pandaEL.x=pandaFL.x=pandaAL.x=this.x-1.5-(this.scaleX-1)*38.5;
      pandaER.x=pandaFR.x=pandaAR.x=this.x+1.5+(this.scaleX-1)*38.5;
    }
    
    pandaA.x=this.x+1.5;
    pandaEL.y=pandaER.y=pandaFL.y=pandaFR.y=pandaAL.y=pandaAR.y=pandaA.y=this.y;

    if(game.jumpC==1){
      pandaEL.image=game.images["PandaEyesL1"];
      pandaER.image=game.images["PandaEyesR1"];
      pandaFL.image=game.images["PandaFootL1"];
      pandaFR.image=game.images["PandaFootR1"];
      pandaAL.visible=false;
      pandaAR.visible=false;
      pandaA.visible=true;

      if(this.y-65>game.trees[game.currentTree].y){
        pandaA.visible=false;
        pandaAL.visible=true;
        pandaAR.visible=true;
      }
    }
    else
    if(game.jumpC==2){
      pandaEL.image=game.images["PandaEyesL2"];
      pandaER.image=game.images["PandaEyesR2"];
      pandaFL.image=game.images["PandaFootL2"];
      pandaFR.image=game.images["PandaFootR2"];
      pandaA.visible=false;
      pandaAL.visible=true;
      pandaAR.visible=true;
    }
  }
}

class TreePiece extends Graphics {
  double xx;
  int segm=1;
  List<Point> segs=new List<Point>();
  Path2D _path;
  double shake=0.0;
  int shakeC=0;
  double shakeV=0.0;

  void init(double x){
    this.x=x;
    this.xx=x;
    this.y=-180+game.minY+(1080-game.minY)*rnd.nextDouble();
    game.minY=this.y;
    this.segm=this.y~/250;
    for(var ss=0; ss<=this.segm; ss++){
      if(ss==0) {
      this.segs.add(new Point(-5+rnd.nextDouble()*10,-250.0-this.y));
      this.segs.add(new Point(-10+rnd.nextDouble()*20, -220.0-this.y+rnd.nextDouble()*190));
      }
      else{
      double ddy=-this.y+(ss-1)*250+rnd.nextDouble()*240;
      this.segs.add(new Point(-5+rnd.nextDouble()*10,ddy));
      if(ss!=this.segm)
      this.segs.add(new Point(-10+rnd.nextDouble()*20, ddy+30+rnd.nextDouble()*190));
      }
    }
    this.segs.add(new Point(-5.0+rnd.nextInt(10), 0.0));

    game.stageTrees.addChild(this,game);
    game.trees.add(this);

    if(x==960.0){
      var poss=this.y~/150+1;
      double rr=rnd.nextDouble();

      int sco=2;

      if(score>30 && score<61)
      sco=3;
      else
      if(score>60)
      sco=4;

      for(var i=1; i<=poss; i++){
        if(rr<0.5){
          rr+=0.5;
        }
        else {
          if(score%(24-(sco*sco))==1 && game.meat==null){
            game.meat=new Meat();
            game.meat.init(this.x-90,i*150.0-120.0,score>5? score%sco: 0);
          }
          else
          if(score>12 && score%5==0){
            Pizza pi=new Pizza();
            pi.init(this.x-90,i*150.0-120.0,score>5? score%sco: 0);
          }
          else {
            Candy ca=new Candy();
            ca.init(this.x-90,i*150.0-120.0,score>5? score%sco: 0);
          }
          rr-=0.5;
        }
      }
    }
  }

  @override
  void update() {
    super.update();
    
    if(shakeC>0){
      if(shakeV>0.04)
      shakeV-=0.04;

      if(shake<0.05 && shakeV<0.05){
        shake=0.0;
        shakeC=0;
      }
      else
      if(shakeC>0 && shakeC<11) {
        shake+=shakeV;
        shakeC+=1;
      }
      else
      if(shakeC>10 && shakeC<31){
        shake-=shakeV;
        shakeC+=1;
      }
      else
      if(shakeC>30 && shakeC<41){
        shake+=shakeV;
        shakeC+=1;

        if(shakeC==41)
        shakeC=1;
      }
    }

    if(game.jumpC==2 && game.currentTree==3 && game.panda.y<desiredSize.y){
      this.x-=12*(0.5/game.panda.weight);

      if(this.x<-300.0 && game.panda.y-60<game.trees[game.currentTree].y){
        game.jumpC=1;
        game.panda.fallSp=0.0;
        game.trees[game.currentTree+1].shakeC=1;
        game.trees[game.currentTree+1].shakeV=4.0;

        if(score>20)
        game.minY=800.0;

        score+=1;

        game.trees.forEach((TreePiece treeP){
          treeP.x=treeP.xx-180;
          treeP.xx=treeP.x;
        });
        game.candys.forEach((Candy c){
          if(c.type<2){
          c.x=c.xx-180;
          c.xx=c.x;
          }
        });
        game.pizzas.forEach((Pizza p){
          if(p.type<2){
          p.x=p.xx-180;
          p.xx=p.x;
          }
        });
        if(game.meat!=null){
          if(game.meat.type<2){
          game.meat.x=game.meat.xx-180;
          game.meat.xx=game.meat.x;
          }
        }
        
        var tree=new TreePiece();
        tree.init(960.0);

        game.trees.remove(this);
        game.stageTrees.removeChild(this, game);
        return;
      }
    }
  }

  @override
  void paint(CanvasRenderingContext2D canvas) {
    super.paint(canvas);
    canvas.setStrokeColorRgb(255, 255, 255);
    canvas.lineWidth=14.0;
    canvas.lineCap="round";
    canvas.lineJoin="round";
    
    _path=Path2D();
    _path.moveTo(this.segs[0].x, this.segs[0].y);
    _path.bezierCurveTo(this.segs[1].x+this.shake*0.1, this.segs[1].y, (this.segs[1].x+this.segs[2].x)/2+this.shake*0.15, (this.segs[1].y+this.segs[2].y)/2, this.segs[2].x+this.shake*0.2, this.segs[2].y);
    for(var pp=2;pp<this.segs.length-2; pp+=2){
      _path.bezierCurveTo(this.segs[pp+1].x+shake*(0.3+(pp-2)*0.075), this.segs[pp+1].y, (this.segs[pp+1].x+this.segs[pp+2].x)/2+shake*(0.35+(pp-2)*0.075), (this.segs[pp+1].y+this.segs[pp+2].y)/2, this.segs[pp+2].x+shake*(0.4+(pp-2)*0.075), this.segs[pp+2].y);
    }
    var xxx=this.segs[this.segs.length-2].x/2+this.segs[this.segs.length-1].x/2;
    var yyy=this.segs[this.segs.length-2].y/2+this.segs[this.segs.length-1].y/2;
    _path.bezierCurveTo(xxx+this.shake*0.85, yyy,(xxx+this.segs[this.segs.length-1].x)/2+this.shake*0.925, (yyy+this.segs[this.segs.length-1].y)/2, this.segs[this.segs.length-1].x+this.shake,this.segs[this.segs.length-1].y);
    _path.closePath();

    canvas.stroke(_path);
  }
}

class Candy extends Graphics {
  List<Point> _points=[Point(-30.0,-11.0),Point(-25.0,-8.0),Point(-15.0,-4.0),Point(15.0,-4.0),Point(25.0,-8.0),Point(30.0,-11.0),Point(26.0,-5.0),Point(30.0,0.0),Point(27.0,6.0),Point(30.0,11.0),Point(25.0,8.0),Point(15.0,4.0),Point(-15.0,4.0),Point(-25.0,8.0),Point(-30.0,11.0),Point(-25.0,5.0),Point(-30.0,0.0),Point(-27.0,-6.0)];
  Path2D _path2d;
  double xx;
  int type=0;
  int con=0;
  double speed=0.0;
  num cMax=20;

  void init(double x, double y, int t){
    this.x=x;
    this.xx=x;
    this.y=y;
    this.type=t;
    

    this._path2d=new Path2D();
    this._path2d.moveTo(this._points[0].x, this._points[0].y);
    for(var i=1; i<this._points.length-1; i++){
      this._path2d.lineTo(this._points[i].x, this._points[i].y);
    }
    this._path2d.closePath();

    if(this.type==1){
      this.speed=0.5+(score-5)/20;

      if(this.speed>3.5)
      this.speed=3.5;

      cMax=(20*3.5/speed)~/1;
    }
    else
    if(this.type==2){
      this.speed=0.5+(score-30)/20;

      if(this.speed>3.5)
      this.speed=3.5;

      cMax=(20*3.5/speed)~/1;
    }
    else
    if(this.type==3){
      this.speed=0.5+(score-60)/20;

      if(this.speed>3.5)
      this.speed=3.5;

      cMax=(20*3.5/speed)~/1;
    }

    this.rotation=rnd.nextDouble()*pi/8;
    
    game.stageFruits.addChild(this, game);
    game.candys.add(this);
  }

  @override
  void update(){
    super.update();
    
    if(game.jumpC==2 && game.currentTree==3 && game.panda.y<desiredSize.y)
      this.x-=12*(0.5/game.panda.weight);

    if(type==1){
      if(this.con<cMax){
      this.y-=this.speed;
      this.con+=1;
      }
      else
      if(this.con<cMax*3){
        this.y+=this.speed;
        this.con+=1;
      }
      else
      if(this.con<cMax*4){
        this.y-=this.speed;
        this.con+=1;
      }
      else
      if(this.con==cMax*4){
        this.con=0;
      }
    }
    else
    if(type==2){
      if(this.con<cMax){
      this.x-=this.speed;
      this.con+=1;
      }
      else
      if(this.con<cMax*3){
        this.x+=this.speed;
        this.con+=1;
      }
      else
      if(this.con<cMax*4){
        this.x-=this.speed;
        this.con+=1;
      }
      else
      if(this.con==cMax*4){
        this.con=0;
      }
    }
    else
    if(type==3){
      if(this.con<cMax){
      this.y-=this.speed;
      this.x-=this.speed;
      this.con+=1;
      }
      else
      if(this.con<cMax*3){
        this.y+=this.speed;
        this.x+=this.speed;
        this.con+=1;
      }
      else
      if(this.con<cMax*4){
        this.y-=this.speed;
        this.x-=this.speed;
        this.con+=1;
      }
      else
      if(this.con==cMax*4){
        this.con=0;
      }
    }

    if(abs(game.panda.x-this.x)<40*game.panda.scaleX+10 && abs(game.panda.y-this.y)<50*game.panda.scaleY+15){
      game.panda.weight+=0.1;
      if(game.panda.weight>2.8)
      game.panda.weight=2.8;
      game.panda.scaleX=game.panda.weight;

      game.panda.scaleY=game.panda.weight/1.66;

      if(game.panda.scaleY<1)
      game.panda.scaleY=1.0;
      game.candys.remove(this);
      game.stageFruits.removeChild(this, game);
      return;
    }

    if(this.x<-100){
      game.candys.remove(this);
      game.stageFruits.removeChild(this, game);
      return;
    }
  }

  @override
  void paint(CanvasRenderingContext2D canvas){
    super.paint(canvas);

    canvas.setStrokeColorRgb(239, 154, 154);
    canvas.lineWidth=2.0;

    canvas.stroke(this._path2d);
    canvas.setFillColorRgb(239, 154, 154);
    canvas.arc(0,0,13,0,2*pi);
    canvas.fill();
  }
}

class Meat extends Sprite {
  double xx;
  int type=0;
  int con=0;
  double speed=0.0;
  num cMax;
  
  Meat():super(game.images["Meat"],Point(-40.5,-17.0));

  void init(double x, double y, int t){
    this.x=x;
    this.xx=x;
    this.y=y;
    this.type=t;

    if(this.type==1){
      this.speed=0.5+(score-5)/20;

      if(this.speed>3.5)
      this.speed=3.5;

      this.cMax=(20*3.5/speed)~/1;
    }
    else
    if(this.type==2){
      this.speed=0.5+(score-30)/20;

      if(this.speed>3.5)
      this.speed=3.5;

      this.cMax=(20*3.5/speed)~/1;
    }
    else
    if(this.type==3){
      this.speed=0.5+(score-60)/20;

      if(this.speed>3.5)
      this.speed=3.5;

      this.cMax=(20*3.5/speed)~/1;
    }

    this.rotation=rnd.nextDouble()*pi/8+pi/8;
    
    game.stageFruits.addChild(this, game);
    game.meat=this;
  }

  @override
  void update(){
    super.update();
    
    if(game.jumpC==2 && game.currentTree==3 && game.panda.y<desiredSize.y)
      this.x-=12*(0.5/game.panda.weight);

    if(this.type==1){
      if(this.con<this.cMax){
      this.y-=this.speed;
      this.con+=1;
      }
      else
      if(this.con<this.cMax*3){
        this.y+=this.speed;
        this.con+=1;
      }
      else
      if(this.con<this.cMax*4){
        this.y-=this.speed;
        this.con+=1;
      }
      else
      if(this.con==this.cMax*4){
        this.con=0;
      }
    }
    else
    if(this.type==2){
      if(this.con<this.cMax){
      this.x-=this.speed;
      this.con+=1;
      }
      else
      if(this.con<this.cMax*3){
        this.x+=this.speed;
        this.con+=1;
      }
      else
      if(this.con<this.cMax*4){
        this.x-=this.speed;
        this.con+=1;
      }
      else
      if(this.con==this.cMax*4){
        this.con=0;
      }
    }
    else
    if(this.type==3){
      if(this.con<this.cMax){
      this.y-=this.speed;
      this.x-=this.speed;
      this.con+=1;
      }
      else
      if(this.con<this.cMax*3){
        this.y+=this.speed;
        this.x+=this.speed;
        this.con+=1;
      }
      else
      if(this.con<this.cMax*4){
        this.y-=this.speed;
        this.x-=this.speed;
        this.con+=1;
      }
      else
      if(this.con==this.cMax*4){
        this.con=0;
      }
    }

    if(abs(game.panda.x-this.x)<40*game.panda.scaleX+10 && abs(game.panda.y-this.y)<50*game.panda.scaleY+15){
      game.panda.weight+=0.7;
      if(game.panda.weight>2.8)
      game.panda.weight=2.8;
      game.panda.scaleX=game.panda.weight;

      game.panda.scaleY=game.panda.weight/1.66;

      if(game.panda.scaleY<1)
      game.panda.scaleY=1.0;
      game.meat=null;
      game.stageFruits.removeChild(this, game);
      return;
    }

    if(this.x<-100){
      game.meat=null;
      game.stageFruits.removeChild(this, game);
      return;
    }
  }
}

class Pizza extends Sprite {
  double xx;
  int type=0;
  int con=0;
  double speed=0.0;
  num cMax;
  
  Pizza():super(game.images["Pizza"],Point(-33.5,-28.0));

  void init(double x, double y, int t){
    this.x=x;
    this.xx=x;
    this.y=y;
    this.type=t;

    if(this.type==1){
      this.speed=0.5+(score-5)/20;

      if(this.speed>3.5)
      this.speed=3.5;

      this.cMax=(20*3.5/speed)~/1;
    }
    else
    if(this.type==2){
      this.speed=0.5+(score-30)/20;

      if(this.speed>3.5)
      this.speed=3.5;

      this.cMax=(20*3.5/speed)~/1;
    }
    else
    if(this.type==3){
      this.speed=0.5+(score-60)/20;

      if(this.speed>3.5)
      this.speed=3.5;

      this.cMax=(20*3.5/speed)~/1;
    }

    this.rotation=rnd.nextDouble()*pi/8+pi/8;
    
    game.stageFruits.addChild(this, game);
    game.pizzas.add(this);
  }

  @override
  void update(){
    super.update();
    
    if(game.jumpC==2 && game.currentTree==3 && game.panda.y<desiredSize.y)
      this.x-=12*(0.5/game.panda.weight);

    if(this.type==1){
      if(this.con<this.cMax){
      this.y-=this.speed;
      this.con+=1;
      }
      else
      if(this.con<this.cMax*3){
        this.y+=this.speed;
        this.con+=1;
      }
      else
      if(this.con<this.cMax*4){
        this.y-=this.speed;
        this.con+=1;
      }
      else
      if(this.con==this.cMax*4){
        this.con=0;
      }
    }
    else
    if(this.type==2){
      if(this.con<this.cMax){
      this.x-=this.speed;
      this.con+=1;
      }
      else
      if(this.con<this.cMax*3){
        this.x+=this.speed;
        this.con+=1;
      }
      else
      if(this.con<this.cMax*4){
        this.x-=this.speed;
        this.con+=1;
      }
      else
      if(this.con==this.cMax*4){
        this.con=0;
      }
    }
    else
    if(this.type==3){
      if(this.con<this.cMax){
      this.y-=this.speed;
      this.x-=this.speed;
      this.con+=1;
      }
      else
      if(this.con<this.cMax*3){
        this.y+=this.speed;
        this.x+=this.speed;
        this.con+=1;
      }
      else
      if(this.con<this.cMax*4){
        this.y-=this.speed;
        this.x-=this.speed;
        this.con+=1;
      }
      else
      if(this.con==this.cMax*4){
        this.con=0;
      }
    }

    if(abs(game.panda.x-this.x)<40*game.panda.scaleX+10 && abs(game.panda.y-this.y)<50*game.panda.scaleY+15){
      game.panda.weight+=0.3;
      if(game.panda.weight>2.8)
      game.panda.weight=2.8;
      game.panda.scaleX=game.panda.weight;

      game.panda.scaleY=game.panda.weight/1.66;

      if(game.panda.scaleY<1)
      game.panda.scaleY=1.0;
      game.pizzas.remove(this);
      game.stageFruits.removeChild(this, game);
      return;
    }
    
  }
}

class Wave1 extends Sprite {
  Wave1():super(game.images["Sea"],Point(0.0,0.0));
}
class Wave2 extends Sprite {
  Wave2():super(game.images["Sea1"],Point(0.0,0.0));
}
class Wave3 extends Sprite {
  Wave3():super(game.images["Sea2"],Point(0.0,0.0));
}

class Wave{
  int con=0;
  int con1=0;
  Collector waveAll;
  List<Sprite> waves=new List<Sprite>();

  void init(double x, double y, int col){
    var w1,w;

    if(col==0)
    w=new Wave1();
    else
    if(col==1)
    w=new Wave2();
    else
    if(col==2)
    w=new Wave3();
    w.x=x;
    w.y=y;
    
    game.stagePanda.addChild(w, game);
    waves.add(w);

    if(col==0)
    w1=new Wave1();
    else
    if(col==1)
    w1=new Wave2();
    else
    if(col==2)
    w1=new Wave3();
    w1.x=x+879.9;
    w1.y=y;
    game.stagePanda.addChild(w1, game);
    waves.add(w1);

    this.con=rnd.nextDouble()*155~/1;

    this.con1=50+rnd.nextDouble()*95~/1;
  }

  void update(){
    if(game.jumpC==2 && game.currentTree==3 && game.panda.y<desiredSize.y){
      this.waves[0].x-=12*(0.5/game.panda.weight);
      this.waves[1].x-=12*(0.5/game.panda.weight);

      if(this.waves[0].x<-880)
      this.waves[0].x=this.waves[1].x+879.9;

      if(this.waves[1].x<-880)
      this.waves[1].x=this.waves[0].x+879.9;
    }

    if(this.con<40){
      this.waves[0].x-=0.5;
      this.waves[1].x-=0.5;
      this.con+=1;
    }
    else
    if(this.con<120){
      this.waves[0].x+=0.5;
      this.waves[1].x+=0.5;
      this.con+=1;
    }
    else
    if(this.con<160){
      this.waves[0].x-=0.5;
      this.waves[1].x-=0.5;
      this.con+=1;
    }
    else
    if(this.con==160){
      this.waves[0].x-=0.5;
      this.waves[1].x-=0.5;
      this.con=0;
    }

    if(this.con1<50){
      this.waves[0].y-=0.1;
      this.waves[1].y-=0.1;
      this.con1+=1;
    }
    else
    if(this.con1<150){
      this.waves[0].y+=0.1;
      this.waves[1].y+=0.1;
      this.con1+=1;
    }
    else
    if(this.con1<200){
      this.waves[0].y-=0.1;
      this.waves[1].y-=0.1;
      this.con1+=1;
    }
    else
    if(this.con1==200){
      this.waves[0].y-=0.1;
      this.waves[1].y-=0.1;
      this.con1=0;
    }
  }
}

class Terrain extends Graphics {
  void init(){
    this.x=0.0;
    this.y=750.0;
    game.stagePanda.addChild(this, game);
  }

  @override
  void paint(CanvasRenderingContext2D canvas) {
    super.paint(canvas);

    canvas.setFillColorRgb(43, 85, 128);
    canvas.rect(0.0, 0.0, 800.0, 300.0);
    canvas.fill();
  }
}

class Hill1 extends Sprite {
  int ind;

  Hill1():super(game.images["Hill1"],Point(0.0,-60.0));

  void init(double x, double y, int i){
    this.x=x;
    this.y=y;
    this.ind=i;
    game.stagePanda.addChild(this, game);
  }

  @override
  void update(){
    super.update();

    if(game.jumpC==2 && game.currentTree==3 && game.panda.y<desiredSize.y){
      this.x-=10*(0.5/game.panda.weight);
    }

    if(this.x<-880){
      this.x=game.hills1[this.ind].x+850;
      this.y=750+rnd.nextDouble()*40;
    }
  }
}

class Hill2 extends Sprite {
  int ind;

  Hill2():super(game.images["Hill2"],Point(0.0,-308.0));

  void init(double x, double y, int i){
    this.x=x;
    this.y=y;
    this.ind=i;
    game.stagePanda.addChild(this, game);
  }

  @override
  void update(){
    super.update();

    if(game.jumpC==2 && game.currentTree==3 && game.panda.y<desiredSize.y){
      this.x-=6*(0.5/game.panda.weight);
    }

    if(this.x<-500){
      this.x=game.hills[this.ind].x+500-rnd.nextInt(250);
      this.y=750+rnd.nextDouble()*200;
    }
  }
}

class Hill3 extends Sprite {
  int ind;

  Hill3():super(game.images["Hill3"],Point(0.0,-204.0));

  void init(double x, double y, int i){
    this.x=x;
    this.y=y;
    this.ind=i;
    game.stagePanda.addChild(this, game);
  }

  @override
  void update(){
    super.update();

    if(game.jumpC==2 && game.currentTree==3 && game.panda.y<desiredSize.y){
      this.x-=6*(0.5/game.panda.weight);
    }

    if(this.x<-500){
      this.x=game.hills[this.ind].x+500-rnd.nextInt(250);
      this.y=750+rnd.nextDouble()*110;
    }
  }
}

class Cloud1 extends Sprite {
  double vx;

  Cloud1():super(game.images["Cloud1"],Point(0.0,0.0));

  void init(double x, double y){
    this.x=x;
    this.y=y;
    this.alpha=204/255;
    this.scaleX=0.3+rnd.nextDouble()*0.7;
    this.scaleY=this.scaleX;
    this.vx=0.5+rnd.nextDouble();
    game.stagePanda.addChild(this, game);
  }

  @override
  void update(){
    super.update();

    this.x-=this.vx;

    if(game.jumpC==2 && game.currentTree==3 && game.panda.y<desiredSize.y){
      this.x-=2*(0.5/game.panda.weight);
    }

    if(this.x<-444){
      this.x=1280.0;
      this.y=rnd.nextDouble()*500;
      this.scaleX=0.3+rnd.nextDouble()*0.7;
      this.scaleY=this.scaleX;
      this.vx=0.5+rnd.nextDouble();
    }
  }
}

class Cloud2 extends Sprite {
  double vx;

  Cloud2():super(game.images["Cloud2"],Point(0.0,0.0));

  void init(double x, double y){
    this.x=x;
    this.y=y;
    this.alpha=204/255;
    this.scaleX=0.3+rnd.nextDouble()*0.7;
    this.scaleY=this.scaleX;
    this.vx=0.5+rnd.nextDouble();
    game.stagePanda.addChild(this, game);
  }

  @override
  void update(){
    super.update();

    this.x-=this.vx;

    if(game.jumpC==2 && game.currentTree==3 && game.panda.y<desiredSize.y){
      this.x-=2*(0.5/game.panda.weight);
    }

    if(this.x<-444){
      this.x=1280.0;
      this.y=rnd.nextDouble()*500;
      this.scaleX=0.3+rnd.nextDouble()*0.7;
      this.scaleY=this.scaleX;
      this.vx=0.5+rnd.nextDouble();
    }
  }
}

class Tree extends Sprite {
  int ind;

  Tree():super(game.images["Tree"],Point(0.0,-222.0));

  void init(double x, double y, int i){
    this.x=x;
    this.y=y;
    this.ind=i;
    game.stagePanda.addChild(this, game);
  }

  @override
  void update(){
    super.update();

    if(game.jumpC==2 && game.currentTree==3 && game.panda.y<desiredSize.y){
      this.x-=8*(0.5/game.panda.weight);
    }

    if(this.x<-300){
      this.x=game.treesB[this.ind].x+300-rnd.nextInt(150);
      this.y=750+rnd.nextDouble()*70;
    }
  }
}