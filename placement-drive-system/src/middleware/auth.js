const pool=require('../config/database');
function requireAuth(req,res,next){if(!req.session.user)return res.status(401).json({ok:false,error:'Authentication required.'});next()}
function requireRole(...roles){return (req,res,next)=>{if(!req.session.user)return res.status(401).json({ok:false,error:'Authentication required.'});if(!roles.includes(req.session.user.role))return res.status(403).json({ok:false,error:'You do not have permission to access this resource.'});next()}}
async function csrf(req,res,next){if(['GET','HEAD','OPTIONS'].includes(req.method))return next();const token=req.get('x-csrf-token');if(!req.session.csrfToken||token!==req.session.csrfToken)return res.status(403).json({ok:false,error:'Invalid CSRF token.'});next()}
async function studentForUser(userId){const [r]=await pool.execute('SELECT * FROM students WHERE user_id=?',[userId]);return r[0]}
module.exports={requireAuth,requireRole,csrf,studentForUser};
