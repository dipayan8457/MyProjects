const express=require("express");
const router=express.Router();
const productController=require("./../controller/productController.js");

router.param("id",productController.checkID);
//app.get("/ecommerce/v1/api",getAllProduct);
//app.post("/ecommerce/v1/api",postPoduct);
//app.get("/ecommerce/v1/api/:id",searchProduct);
//app.patch("/ecommerce/v1/api/:id",updateProduct);
//app.delete("/ecommerce/v1/api/:id",deleteProduct);

router.route("/").get(productController.getAllProduct).post(productController.checkBody,productController.postPoduct);
router.route("/:id").get(productController.getOneProduct).patch(productController.patchProduct).delete(productController.deleteProduct);

module.exports=router;

//router works like an express server to handle requests passed on from app