import { application } from "controllers/application"
import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"

// Only import controllers that are actually used
import ListingsSearchController from "./listings_search_controller"
application.register("listings-search", ListingsSearchController)

// Lazy load any other controllers as needed
lazyLoadControllersFrom("controllers", application)
