import {Router} from 'express';
import {createLandmark, deleteLandmark, getLandmark, getLandmarks, updateLandmark} from '../controllers/landmarks.controller.ts';

const router = Router();

router.get('/', getLandmarks);
router.get('/:id', getLandmark);
router.post('/', createLandmark);
router.patch('/:id', updateLandmark);
router.delete('/:id', deleteLandmark);

export default router;
