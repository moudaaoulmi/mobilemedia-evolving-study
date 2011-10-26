/*
 * Lancaster University
 * Computing Department
 * 
 * Created by Eduardo Figueiredo
 * Date: 9 Aug 2007
 * 
 */
package lancs.midp.mobilephoto.optional;

import lancs.midp.mobilephoto.optional.copyPhoto.CopyPhotoAspect;
import lancs.midp.mobilephoto.optional.favourites.FavouritesAspect;
import lancs.midp.mobilephoto.optional.favourites.PersisteFavoritesAspect;
import lancs.midp.mobilephoto.optional.sorting.CountViewsAspect;
import lancs.midp.mobilephoto.optional.sms.SMSAspect;

/**
 * @author Eduardo Figueiredo
 *
 */
public aspect OptionalFeatureAspect {

	declare precedence : SMSAspect, CopyPhotoAspect, FavouritesAspect, CountViewsAspect, PersisteFavoritesAspect; // [EF] Checked Ok??


}
