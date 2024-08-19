const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // Carpeta donde se guardarán las imágenes
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname)); // Nombre único para el archivo
  },
});

const upload = multer({ storage: storage });



const app = express();
const port = 3000;
const secretKey = '2002'; // Cambia esto por una clave secreta segura

app.use(bodyParser.json());

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '', // tu contraseña de MySQL
  database: 'floreser'
});

db.connect(err => {
  if (err) {
    console.error('Error connecting to MySQL:', err);
    process.exit(1);
  }
  console.log('MySQL connected...');
});

function verifyToken(req, res, next) {
  const token = req.headers['x-access-token'];
  if (!token) return res.status(401).send('Access Denied');

  try {
    const verified = jwt.verify(token, secretKey);
    req.userId = verified.id;
    next();
  } catch (err) {
    res.status(400).send('Invalid Token');
  }
}

// Registro de usuarios
app.post('/register', async (req, res) => {
  const { email, username, password, security_question_1, security_answer_1, security_question_2, security_answer_2, fingerprint } = req.body;

  if (!email || !username || !password || !security_question_1 || !security_answer_1 || !security_question_2 || !security_answer_2) {
    return res.status(400).json({ message: 'Todos los campos son obligatorios, excepto la huella dactilar' });
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const sql = 'INSERT INTO users (email, username, password, security_question_1, security_answer_1, security_question_2, security_answer_2, fingerprint) VALUES (?, ?, ?, ?, ?, ?, ?, ?)';
    db.query(sql, [email, username, hashedPassword, security_question_1, security_answer_1, security_question_2, security_answer_2, fingerprint], (err, result) => {
      if (err) {
        console.error('Error registrando usuario:', err);
        return res.status(500).json({ message: 'Error registrando usuario', error: err });
      }

      const token = jwt.sign({ id: result.insertId }, secretKey, { expiresIn: '1h' });
      res.status(200).json({ message: 'Registro exitoso', token });
    });
  } catch (err) {
    res.status(500).json({ message: 'Error al registrar usuario', error: err });
  }
});

// Login de usuarios
app.post('/login', (req, res) => {
  const { username, password } = req.body;

  const sql = 'SELECT * FROM users WHERE username = ?';
  db.query(sql, [username], (err, results) => {
    if (err) {
      console.error('Error al buscar usuario:', err);
      return res.status(500).send('Error al buscar usuario');
    }
    if (results.length === 0) return res.status(404).send('User not found');

    const user = results[0];
    const passwordIsValid = bcrypt.compareSync(password, user.password);
    if (!passwordIsValid) return res.status(401).send('Invalid password');

    const token = jwt.sign({ id: user.id }, secretKey, { expiresIn: '24h' });

    res.status(200).send({ auth: true, token });
  });
});

// Obtener información del usuario
app.get('/user-info', verifyToken, (req, res) => {
  // Realiza una consulta con JOIN para obtener la información del usuario y su dirección
  const query = `
    SELECT users.username, users.email, direccion.street, direccion.city, direccion.state, direccion.postal_code, direccion.country
    FROM users
    LEFT JOIN direccion ON users.username = direccion.username
    WHERE users.id = ?
  `;

  db.query(query, [req.userId], (err, results) => {
    if (err) {
      console.error('Error al obtener información del usuario:', err);
      return res.status(500).send('Error en el servidor');
    }
    if (results.length === 0) {
      return res.status(404).send('No se encontró el usuario');
    }

    // Responder con la información del usuario y la dirección
    res.status(200).send({
      username: results[0].username,
      email: results[0].email,
      address: {
        street: results[0].street || 'Sin calle registrada',
        city: results[0].city || 'Sin ciudad registrada',
        state: results[0].state || 'Sin estado registrado',
        postal_code: results[0].postal_code || 'Sin código postal registrado',
        country: results[0].country || 'Sin país registrado',
      }
    });
  });
});


// Olvidó su contraseña
app.post('/forgot-password', (req, res) => {
  const { email } = req.body;

  const sql = 'SELECT security_question_1, security_question_2 FROM users WHERE email = ?';
  db.query(sql, [email], (err, results) => {
    if (err) {
      console.error('Error al buscar el correo:', err);
      return res.status(500).send('Error al buscar el correo');
    }
    if (results.length === 0) return res.status(404).send('Correo no encontrado');

    const user = results[0];
    res.status(200).send({ security_question_1: user.security_question_1, security_question_2: user.security_question_2 });
  });
});


// Verificar respuestas de seguridad
app.post('/verify-security-answers', (req, res) => {
  const { email, security_answer_1, security_answer_2 } = req.body;

  const sql = 'SELECT id, security_answer_1, security_answer_2 FROM users WHERE email = ?';
  db.query(sql, [email], (err, results) => {
    if (err) {
      console.error('Error al verificar respuestas de seguridad:', err);
      return res.status(500).send('Error en el servidor');
    }
    if (results.length === 0) return res.status(404).send('Correo no encontrado');

    const user = results[0];
    const answer1IsValid = bcrypt.compareSync(security_answer_1, user.security_answer_1);
    const answer2IsValid = bcrypt.compareSync(security_answer_2, user.security_answer_2);

    if (answer1IsValid && answer2IsValid) {
      const token = jwt.sign({ id: user.id }, secretKey, { expiresIn: '1h' });
      res.status(200).send({ token });
    } else {
      res.status(401).send('Respuestas de seguridad incorrectas');
    }
  });
});

// Cambiar contraseña
app.post('/change-password', (req, res) => {
  const { email, newPassword } = req.body;

  if (!email || !newPassword) {
    return res.status(400).send('Correo electrónico y nueva contraseña son requeridos');
  }

  const hashedPassword = bcrypt.hashSync(newPassword, 10);

  const sql = 'UPDATE users SET password = ? WHERE email = ?';

  db.query(sql, [hashedPassword, email], (err, result) => {
    if (err) {
      console.error('Error al cambiar la contraseña:', err);
      return res.status(500).send('Error al cambiar la contraseña');
    }
    if (result.affectedRows === 0) {
      return res.status(404).send('Usuario no encontrado');
    }
    res.status(200).send('Contraseña cambiada exitosamente');
  });
});

// Cambiar nombre de usuario
app.post('/cambiar-usuario', (req, res) => {
  const { userId, newUsername } = req.body;

  if (!userId || !newUsername) {
    return res.status(400).send('Faltan parámetros');
  }

  const query = 'UPDATE users SET username = ? WHERE id = ?';
  db.query(query, [newUsername, userId], (err, results) => {
    if (err) {
      console.error('Error al cambiar el nombre de usuario:', err);
      return res.status(500).send('Error en la base de datos');
    }
    if (results.affectedRows === 0) {
      return res.status(404).send('Usuario no encontrado');
    }
    res.status(200).send('Nombre de usuario actualizado');
  });
});

// Agregar dirección
app.post('/api/registerAddress', (req, res) => {
  const { username, street, city, state, postal_code, country } = req.body;

  // Verifica que todos los campos requeridos estén presentes
  if (!username || !street || !city || !state || !postal_code || !country) {
    return res.status(400).send('Todos los campos son obligatorios');
  }

  // Consulta SQL para insertar una nueva dirección en la base de datos
  const query = 'INSERT INTO direccion (username, street, city, state, postal_code, country) VALUES (?, ?, ?, ?, ?, ?)';
  db.query(query, [username, street, city, state, postal_code, country], (err, result) => {
    if (err) {
      console.error('Error al registrar la dirección:', err);
      return res.status(500).send('Error al registrar la dirección');
    }
    res.status(200).send('Dirección registrada exitosamente');
  });
});

app.post('/changeAddress', (req, res) => {
  const { username, street, city, state, postal_code, country } = req.body;

  if (!username || !street || !city || !state || !postal_code || !country) {
    return res.status(400).send('Todos los campos de dirección y nombre de usuario son requeridos');
  }

  const sql = 'UPDATE direccion SET street = ?, city = ?, state = ?, postal_code = ?, country = ? WHERE username = ?';

  db.query(sql, [street, city, state, postal_code, country, username], (err, result) => {
    if (err) {
      console.error('Error al cambiar la dirección:', err);
      return res.status(500).send('Error al cambiar la dirección');
    }
    if (result.affectedRows === 0) {
      return res.status(404).send('Dirección no encontrada para el usuario');
    }
    res.status(200).send('Dirección cambiada exitosamente');
  });
});


// Guardar huella digital
app.post('/save-fingerprint', verifyToken, (req, res) => {
  const { fingerprintData } = req.body;
  const userId = req.userId;

  if (!fingerprintData) {
    return res.status(400).send('Fingerprint data is required');
  }

  const query = 'UPDATE users SET fingerprint = ? WHERE id = ?';
  db.query(query, [fingerprintData, userId], (err, results) => {
    if (err) {
      console.error('Error al guardar la huella digital:', err);
      return res.status(500).send('Error al guardar la huella digital');
    }
    res.status(200).send('Huella digital guardada exitosamente');
  });
});

// Verificar huella digital
app.post('/verify-fingerprint', (req, res) => {
  const { fingerprintData } = req.body;

  if (!fingerprintData) {
    return res.status(400).send('Fingerprint data is required');
  }

  const sql = 'SELECT username, password FROM users WHERE fingerprint = ?';
  db.query(sql, [fingerprintData], (err, results) => {
    if (err) {
      console.error('Error al verificar huella digital:', err);
      return res.status(500).send('Error en la base de datos');
    }
    if (results.length === 0) {
      return res.status(404).send('Huella no reconocida');
    }

    const user = results[0];
    res.status(200).json({ username: user.username, password: user.password });
  });
});

// Registrar producto
// Endpoint para registrar un producto
app.post('/api/registerProduct', upload.single('image'), (req, res) => {
  const { nombre, descripcion, precio, id_categoria, cantidad } = req.body;
  const image = req.file ? req.file.filename : null; // Obtiene el nombre del archivo si se subió

  // Verifica que todos los campos requeridos estén presentes
  if (!nombre || !descripcion || !precio || !id_categoria || cantidad === undefined) {
    return res.status(400).send('Todos los campos son obligatorios');
  }

  // Consulta SQL para insertar un nuevo producto en la base de datos
  const query = 'INSERT INTO products (nombre, descripcion, precio, id_categoria, cantidad, image) VALUES (?, ?, ?, ?, ?, ?)';
  db.query(query, [nombre, descripcion, precio, id_categoria, cantidad, image], (err, result) => {
    if (err) {
      console.error('Error al registrar producto:', err);
      return res.status(500).send('Error al registrar producto');
    }
    res.status(200).send('Producto registrado exitosamente');
  });
});

// Servir archivos estáticos (imágenes) desde la carpeta 'uploads'
app.use('/uploads', express.static('uploads'));


// Obtener todos los productos
app.get('/api/products', (req, res) => {
  const query = 'SELECT * FROM products';

  db.query(query, (err, results) => {
    if (err) {
      console.error('Error al obtener productos:', err);
      return res.status(500).send('Error al obtener productos');
    }
    res.status(200).json(results);
  });
});

// Agregar una ruta para procesar la compra
app.post('/api/process-purchase', (req, res) => {
  const { products } = req.body;

  if (!products || !Array.isArray(products)) {
    return res.status(400).send('Productos no válidos');
  }

  // Verificar que hay productos en la compra
  if (products.length === 0) {
    return res.status(400).send('El carrito está vacío');
  }

  // Procesar cada producto en la compra
  products.forEach(product => {
    const { id, cantidad } = product;

    if (!id || cantidad === undefined) {
      return res.status(400).send('Datos del producto inválidos');
    }

    // Actualizar la cantidad del producto en la base de datos
    const updateQuery = 'UPDATE products SET cantidad = cantidad - ? WHERE id = ?';
    db.query(updateQuery, [cantidad, id], (err, result) => {
      if (err) {
        console.error('Error al actualizar la cantidad del producto:', err);
        return res.status(500).send('Error al procesar la compra');
      }
      // Verificar si la actualización fue exitosa
      if (result.affectedRows === 0) {
        return res.status(404).send('Producto no encontrado');
      }
    });
  });

  res.status(200).send('Compra procesada exitosamente');
});

app.put('/change-email', verifyToken, (req, res) => {
  const { username, new_email } = req.body;

  if (!username || !new_email) {
    return res.status(400).send('Nombre de usuario y nuevo correo electrónico son requeridos');
  }

  // Actualiza el correo electrónico del usuario en la base de datos
  const sql = 'UPDATE users SET email = ? WHERE username = ?';

  db.query(sql, [new_email, username], (err, result) => {
    if (err) {
      console.error('Error al actualizar el correo electrónico:', err);
      return res.status(500).send('Error al actualizar el correo electrónico');
    }
    if (result.affectedRows === 0) {
      return res.status(404).send('Usuario no encontrado');
    }
    res.status(200).send('Correo electrónico actualizado exitosamente');
  });
});




// Iniciar servidor
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
