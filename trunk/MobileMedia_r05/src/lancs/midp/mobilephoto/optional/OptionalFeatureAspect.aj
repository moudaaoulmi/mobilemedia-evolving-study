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

/**
 * @author Eduardo Figueiredo
 *
 */
public aspect OptionalFeatureAspect {

	declare precedence : CopyPhotoAspect, FavouritesAspect, CountViewsAspect, PersisteFavoritesAspect; // [EF] Checked Ok??


}
