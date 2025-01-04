const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');  // JWT için gerekli
const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

const JWT_SECRET = 'health_sync_secret_key';  // JWT için secret key

// Mock database
const mockDb = {
  users: [], // { id, email, name, height, weight, age, created_at }
  exercises: [],
  nutrition: [],
  tokens: {}
 };

// Login endpoint
app.post('/auth/login', (req, res) => {
  const { email, password } = req.body;
  
  // Email'e göre kullanıcıyı bul
  const user = mockDb.users.find(u => u.email === email);
  if (!user) {
    return res.status(401).json({ message: 'User not found' });
  }
 
  // JWT payload
  const payload = {
    user_id: user.id.toString(), // Sabit "1" yerine gerçek user ID'yi kullan
    email: email,
    roles: ["user"],
    exp: Math.floor(Date.now() / 1000) + (60 * 60)
  };
 
  const token = jwt.sign(payload, JWT_SECRET);
  const refreshToken = jwt.sign({ user_id: user.id.toString() }, JWT_SECRET);
 
  const response = {
    user_id: user.id.toString(),
    email: email,
    token: token,
    refresh_token: refreshToken,
    profile: {
      id: user.id,
      name: user.name,
      height: user.height,
      weight: user.weight,
      age: user.age,
      created_at: user.created_at
    }
  };
 
  mockDb.tokens[token] = response;
  res.json(response);
 });

// Register endpoint
app.post('/auth/register', (req, res) => {
 const { email, password, name, height, weight, age } = req.body;
 console.log('Register isteği:', req.body);

 const user = {
  id: mockDb.users.length + 1,
  email,  // Email'i ekleyin
  name,
  height,
  weight,
  age,
  created_at: new Date().toISOString()
};

 // JWT payload
 const payload = {
  user_id: user.id.toString(),  // Unique ID'yi token'a ekliyoruz
  email: email,
  roles: ["user"],
  exp: Math.floor(Date.now() / 1000) + (60 * 60)
};

 const token = jwt.sign(payload, JWT_SECRET);
 const refreshToken = jwt.sign({ user_id: user.id.toString() }, JWT_SECRET);

 const response = {
   user_id: user.id.toString(),
   email,
   token: token,
   refresh_token: refreshToken,
   profile: user
 };

 mockDb.users.push(user);
 mockDb.tokens[token] = response;
 console.log('Register yanıtı:', response);
 res.json(response);
});

// Token yenileme endpoint'i
app.post('/auth/refresh', (req, res) => {
 const { refresh_token } = req.body;
 try {
   const decoded = jwt.verify(refresh_token, JWT_SECRET);
   const payload = {
     user_id: decoded.user_id,
     roles: ["user"],
     exp: Math.floor(Date.now() / 1000) + (60 * 60)
   };

   const newToken = jwt.sign(payload, JWT_SECRET);
   const newRefreshToken = jwt.sign({ user_id: decoded.user_id }, JWT_SECRET);

   res.json({
     token: newToken,
     refresh_token: newRefreshToken
   });
 } catch (error) {
   res.status(401).json({ message: 'Invalid refresh token' });
 }
});

// Exercise endpoint
app.post('/exercises', (req, res) => {
 const { user_id, name, duration, calories_burned } = req.body;
 const token = req.headers.authorization?.split(' ')[1];

 if (!token || !mockDb.tokens[token]) {
   return res.status(401).json({ message: 'Unauthorized' });
 }
 
 const exercise = {
   id: mockDb.exercises.length + 1,
   user_id: parseInt(user_id),
   name,
   duration,
   calories_burned,
   date: new Date().toISOString()
 };

 mockDb.exercises.push(exercise);
 res.json(exercise);
});

// Nutrition endpoint
app.post('/nutrition', (req, res) => {
 const { user_id, food_name, calories, protein, carbs, fat } = req.body;
 const token = req.headers.authorization?.split(' ')[1];

 if (!token || !mockDb.tokens[token]) {
   return res.status(401).json({ message: 'Unauthorized' });
 }
 
 const nutrition = {
   id: mockDb.nutrition.length + 1,
   user_id: parseInt(user_id),
   food_name,
   calories,
   protein,
   carbs,
   fat,
   consumed_at: new Date().toISOString()
 };

 mockDb.nutrition.push(nutrition);
 res.json(nutrition);
});

app.listen(port, () => {
 console.log(`Mock API sunucusu http://localhost:${port} adresinde çalışıyor`);
});