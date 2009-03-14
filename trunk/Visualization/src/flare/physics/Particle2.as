package flare.physics
{
	/**
	 * Represents a Particle2 in a physics simulation. A particle is a 
	 * point-mass (or point-charge) subject to physical forces.
	 */
	public class Particle2 extends Particle
	{
		/** Angle of the particle. */
		public var angle:Number=0;
		
		/** Radial distance of the particle */
		public var radial_distance: Number=0;
		
		/** The angular velocity of the particle. */
		public var va:Number=0;
		/** A temporary angular velocity variable. */
		public var _va:Number=0;
		/** The radial velocity of the particle. */
		public var vr:Number=0;
		/** A temporary radial velocity variable. */
		public var _vr:Number=0;
		/** The angular force exerted on the particle. */
		public var fa:Number=0;
		/** The radial force exerted on the particle. */
		public var fr:Number=0;
		
		public function Particle2(mass:Number=1, x:Number=0, y:Number=0,
								 vx:Number=0, vy:Number=0, fixed:Boolean=false)
		{
			super (mass, x, y, vx, vy, fixed);
		}

	} // end of class Particle2
}