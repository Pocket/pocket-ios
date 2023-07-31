#  CoreData Relationships

At Pocket we use NSFetchedResultsControllers to power our data views. These work great and update our views only when the object they are observing updates its values. However it has a downside where Core Data will not tell NSFetchedResultsController to update if the object it is montioring has an update to any of its related objects.

For Pocket this causes problem for our Home screen where our root object is Recommendation, but we need to display changes to the Recommendation if the user clicks Save, which in itself is a completely different object.

The code in this directory is modified from https://www.avanderlee.com/swift/nsfetchedresultscontroller-observe-relationship-changes/ which describes the problem in more detail. This lets us build a FetchRequest and NSFetchedResultsController that can monitor changes in the entity relationships. 

However, it only originally supported 1 level deep of relationships and for Recommendations we need to support at least 2 levels, where the levels are Recommendations -> Item -> SavedItem.  

