import { application } from "controllers/application"
import HelloController from "controllers/hello_controller"
import ListingsSearchController from "controllers/listings_search_controller"

application.register("hello", HelloController)
application.register("listings-search", ListingsSearchController)
