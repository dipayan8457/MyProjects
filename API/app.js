const express = require("express");
const morgan=require("morgan");
const productRouter=require("./router/productRouter.js");

    const app=express();
    app.use(express.json());
    app.use(morgan("dev"));
    
    app.use("/api/v1/ecommerce",productRouter);

    module.exports=app;
    




