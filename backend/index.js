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
    port:'8080'
})

db.connect(err =>{
    if(err){
        throw err;
    }
    console.log('Se conecto :)')
})

app.get('/api/v1/alumnos',(req , res) =>{
    const sql = 'SELECT * FROM alumnos';
    db.query(sql,(err, result)=>{
        if(err){
            throw err;
        }
        res.json(result)
    });
});

app.listen(PORT,()=>{
    console.log('El servidor esta corriendo');
})