import { application } from "./application"
import HelloController from "./hello_controller"
import ListingsSearchController from "./listings_search_controller"

application.register("hello", HelloController)
application.register("listings-search", ListingsSearchController)
