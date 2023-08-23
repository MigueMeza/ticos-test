const express = require ('express');
const mysql = require('mysql');
const app = express();
const PORT = process.env.PORT || 3000;


app.use(express.json());

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'admin',
    database:'escuela',
    port:'3306'
})

db.connect(err =>{
    if(err){
        throw err;
    }
    console.log('Se conecto :)')
})
//obtener todos lo alumnos
app.get('/api/v1/alumnos',(req , res) =>{
    const sql = 'SELECT * FROM alumnos';
    db.query(sql,(err, result)=>{
        if(err){
            throw err;
        }
        res.json(result);
    });
});

//obtener un alumno
app.get('/api/v1/:id',(req , res) =>{
    const itemid = req.params.id;
    
    const sql= 'SELECT * FROM alumnos WHERE id = ?';
    db.query(sql,[itemid],(err, result)=>{
        if(err){
            throw err;
        }
        res.json(result[0]);
    });
});

//metodo post
app.post('/api/v1/insert',(req,res) => {
    const nuevo_id = req.query.id;
    const nuevo_nombre = req.query.nombre;
    const nuevo_direccion = req.query.direccion;
    const sql = 'INSERT INTO alumnos (id, nombre, direccion) values ('+nuevo_id+',"'+nuevo_nombre+'","'+nuevo_direccion+'")';
    db.query(sql,(err, result) => {
        if(err){
            throw err;
        }
        res.json({message:'Usuario creado exitosamente'})
    });
});

//metodo update
app.post('/api/v1/update',(req,res) => {
    const nuevo_id = req.query.id;
    const nuevo_nombre = req.query.nombre;
    const nuevo_direccion = req.query.direccion;
    const sql = 'update alumnos set nombre = "'+nuevo_nombre+'", direccion = "'+nuevo_direccion+'" where id = '+nuevo_id;
    db.query(sql,(err, result) => {
        if(err){
            throw err;
        }
        res.json({message:'Tabla actualizada exitosamente'})
    });
});

app.listen(PORT,()=>{
    console.log('El servidor esta corriendo');
})