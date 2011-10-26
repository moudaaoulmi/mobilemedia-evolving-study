/*
 * Lancaster University
 * Computing Department
 * 
 * Created by Eduardo Figueiredo
 * Date: 9 Aug 2007
 * 
 */
package lancs.midp.mobilephoto.optional.favourites;

import ubc.midp.mobilephoto.core.ui.datamodel.ImageData;
import ubc.midp.mobilephoto.core.util.ImageUtil;

/**
 * @author Eduardo Figueiredo
 *
 */
public aspect PersisteFavoritesAspect {

	// TODO [EF] This pointcut is already defined in aspect UtilAspectEH and CountViewsAspect 
	//Method public String ImageUtil.getBytesFromImageInfo(ImageData ii) 1- block - Scenario 1
	pointcut getBytesFromImageInfo(ImageData ii): 
		 execution(public String ImageUtil.getBytesFromImageInfo(ImageData)) && args(ii);
	
	String around(ImageData ii) : getBytesFromImageInfo(ii) {
//		System.out.println("<* FavouritesAspect.around getBytesFromImageInfo *> begins...");
		
		String byteString = proceed(ii);
		
		// [EF] Added in scenario 03
		byteString = byteString.concat(ImageUtil.DELIMITER);
		if (ii.isFavorite()) byteString = byteString.concat("true");
		else byteString = byteString.concat("false");
		
//		System.out.println("<* FavouritesAspect.around getBytesFromImageInfo *> ...ends");
		return byteString;
	}
	
}
