package lancs.midp.mobilephoto.alternative.photomusicvideo;

import javax.microedition.lcdui.Display;

import ubc.midp.mobilephoto.core.ui.MainUIMidlet;
import ubc.midp.mobilephoto.core.ui.controller.BaseController;
import ubc.midp.mobilephoto.core.ui.controller.ScreenSingleton;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.screens.AlbumListScreen;
import ubc.midp.mobilephoto.core.util.Constants;
import lancs.midp.mobilephoto.alternative.photo.PhotoAspect;
import lancs.midp.mobilephoto.alternative.music.MusicAspect;
import lancs.midp.mobilephoto.alternative.video.VideoAspect;
import lancs.midp.mobilephoto.optional.OptionalFeatureAspect;

public aspect PhotoAndMusicAndVideo {

		declare precedence : MusicAspect, VideoAspect, PhotoAspect, PhotoAndMusicAndVideo, OptionalFeatureAspect; // [EF] Check? 
		
		// ********  MainUIMidlet  ********* //
		
		//public void startApp()
		pointcut startApp(MainUIMidlet midlet):
			execution( public void MainUIMidlet.startApp() ) && this(midlet);
		
		after(MainUIMidlet midlet): startApp(midlet) {
			System.out.println("Start after photoandall ..."+midlet);
			BaseController imageRootController = PhotoAspect.aspectOf().imageRootController;
			AlbumData imageModel = PhotoAspect.aspectOf().imageModel;

			BaseController musicRootController = MusicAspect.aspectOf().musicRootController;
			AlbumData musicModel = MusicAspect.aspectOf().musicModel;
			
			BaseController videoRootController = VideoAspect.aspectOf().videoRootController;
			AlbumData videoModel = VideoAspect.aspectOf().videoModel;
			System.out.println("Obteve as referencias ");
			AlbumListScreen albumListScreen = (AlbumListScreen)imageRootController.getAlbumListScreen();
			
			// [NC] Added in the scenario 07
			System.out.println("Vai criar o selectmediacontroller ");
			SelectMediaController selectcontroller = new SelectMediaController(midlet, imageModel, albumListScreen);
			selectcontroller.setNextController(imageRootController);
			
			selectcontroller.setImageAlbumData(imageModel);
			selectcontroller.setImageController(imageRootController);
			
			selectcontroller.setMusicAlbumData(musicModel);
			selectcontroller.setMusicController(musicRootController);
			
			selectcontroller.setVideoAlbumData(videoModel);
			selectcontroller.setVideoController(videoRootController);
			System.out.println("Vai definir a tela principal");
			SelectTypeOfMedia mainscreen = new SelectTypeOfMedia();
			System.out.println("Crio a tela");
			mainscreen.initMenu();
			System.out.println("apagou os itens");
			mainscreen.append("Photos");
			mainscreen.append("Music");
			mainscreen.append("Videos");
			System.out.println("definiu os items");
			mainscreen.setCommandListener(selectcontroller);
			System.out.println("definiu o controler");
			Display.getDisplay(midlet).setCurrent(mainscreen);
			System.out.println("definiu a tela");
			ScreenSingleton.getInstance().setMainMenu(mainscreen);
			
			System.out.println("finish after photoandall ...");
		}

		// ********  BaseController  ********* //
		
		//private boolean goToPreviousScreen())
		pointcut goToPreviousScreen(BaseController controller):
			execution( private boolean BaseController.goToPreviousScreen() ) && this(controller);
		
		boolean around(BaseController controller) : goToPreviousScreen(controller) {
			boolean returned = proceed(controller);
			if (returned) return true;
			
	    	String currentScreenName = ScreenSingleton.getInstance().getCurrentScreenName();
			// [NC] Added in the scenario 07
			if ((currentScreenName == null) || (currentScreenName.equals(Constants.ALBUMLIST_SCREEN))) {	
				controller.setCurrentScreen( ScreenSingleton.getInstance().getMainMenu() );
				return true;
			}
			return false;
		}
		
		// ********  ScreenSingleton  ********* //
		
		// [NC] Added in the scenario 07
		private SelectTypeOfMedia ScreenSingleton.mainscreen;
		
		public SelectTypeOfMedia ScreenSingleton.getMainMenu(){
			return mainscreen;
		}
		
		public void ScreenSingleton.setMainMenu(SelectTypeOfMedia screen){
			mainscreen = screen;
		}
		
	}