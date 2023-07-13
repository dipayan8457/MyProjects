const fs = require("fs");

const obj=fs.readFileSync(`${__dirname}/../data/productData.json`,"utf-8");
const productData=JSON.parse(obj);  

exports.checkID = (req,res,next,id)=>{
    if(id>productData.length){
        return res.status(400).json({
            "status":"Wrong request id"
        });
    }
    next();
}
exports.getAllProduct = (req,res)=>{
    res.status(200).json({
        status : "success",
        data : {productData}
    });
};
exports.checkBody = (req,res,next)=>{
    if(!req.body.name){
        return res.status(400).json({
            "status":"Enter name"
        });
    }
    next();
}
exports.postPoduct = (req,res)=>{
    const newId=productData[productData.length-1].id + 1;
    const newProduct=Object.assign({"id":newId},req.body);
    productData.push(newProduct);
    fs.writeFile(`${__dirname}/../data/productData.json`,JSON.stringify(productData),"utf-8",(err)=>{//error handler function of async function
       if(err){
        res.status(400).json({
            status:"error"
        })
       }
       else{
        res.status(200).json({
            status:"success",
            data:{productData}
        })
       }
    });
};
exports.getOneProduct = (req,res)=>{
    const id=req.params.id * 1;
    const searchProduct=productData.find((element)=>element.id==id);
    res.status(200).json({
        status : "success",
        data : {searchProduct}
    });
};
exports.patchProduct = (req,res)=>{
    const id=req.params.id * 1;
    let updatedProduct=productData.find((element)=>element.id==id);
    const updatedIndex=productData.indexOf(updatedProduct);
    Object.assign(updatedProduct,req.body);
    productData[updatedIndex]=updatedProduct;
    fs.writeFile(`${__dirname}/../data/productData.json`,JSON.stringify(productData),"utf-8",(err)=>{
        res.status(404).json({
            "status":"error"
        })
    });
    console.log(updatedProduct);
    res.status(200).json({
        "status":"success",
        "data":{updatedProduct}
    });
};
exports.deleteProduct = (req,res)=>{
    const id=req.params.id * 1;
    let deletedProduct=productData.find((element)=>element.id==id);
    const deletedIndex=productData.indexOf(deletedProduct);
    productData.splice(deletedIndex,1);
    fs.writeFile(`${__dirname}/../data/productData.json`,JSON.stringify(productData),"utf-8",(err,data)=>{
        res.status(404).json({
            "status":"error"
        })
    });
    res.status(200).json({
        "status":"success",
    });
};
