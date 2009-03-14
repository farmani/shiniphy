package flare.physics
{
	/**
	 * Force simulating a spring force between two particles. This force
	 * iterates over each <code>Spring</code> instance in a simulation and
	 * computes the spring force between the attached particles. Spring forces
	 * are computed using Hooke's Law plus a damping term modeling frictional
	 * forces in the spring.
	 * 
	 * <p>The actual equation is of the form: <code>F = -k*(d - L) + a*d*(v1 - 
	 * v2)</code>, where k is the spring tension, d is the distance between
	 * particles, L is the rest length of the string, a is the damping
	 * co-efficient, and v1 and v2 are the velocities of the particles.</p>
	 */
	public class SpringForce2 implements IForce
	{		
		public function apply(sim:Simulation):void{}

		/**
		 * Applies this force to a simulation.
		 * @param sim the Simulation to apply the force to
		 */
		public function apply2(sim:Simulation2):void
		{
			var s:Spring, p1:Particle2, p2:Particle2;
			var dx:Number, dy:Number, dn:Number, dd:Number, k:Number, fx:Number, fy:Number;
			
			for (var i:uint=0; i<sim.springs.length; ++i) {
				s = Spring(sim.springs[i]);
				p1 = s.p1 as Particle2;
				p2 = s.p2 as Particle2;
				if(p1 == null || p2 == null)
					throw new Error("Spring doesnt have a Particle");				
				var cx:Number = 400, cy:Number = 400;
				var len1:Number = Math.sqrt((p1.x-cx)*(p1.x-cx) + (p1.y-cy)*(p1.y-cy))+1;
				var len2:Number = Math.sqrt((p2.x-cx)*(p2.x-cx) + (p2.y-cy)*(p2.y-cy))+1;
				var angle:Number = Math.acos(((p1.x-cx)*(p2.x-cx) + (p1.y-cy)*(p2.y-cy))/len1/len2);
				dn=angle;
				/* dx = p1.x/len1 - p2.x/len2;
				dy = p1.y/len1 - p2.y/len2;
				dn = Math.sqrt(dx*dx + dy*dy);
				*/dd = dn<1 ? 1 : dn;
 				k  = s.tension * (dn - s.restLength);
				//k += s.damping * (dx*(p1.vx-p2.vx) + dy*(p1.vy-p2.vy)) / dd;
				k /= dd;
				
				// provide a random direction when needed
				if (dn==0) {
					dx = 0.01 * (0.5-Math.random());
					dy = 0.01 * (0.5-Math.random());
				}
				
				//fx = -k * dx * len2;
				//fy = -k * dy * len2;
				
				//Nullify the radial component of the force
				//The 2nd particle is the one we are interested in
				var ct1:Number = (p1.x-cx)/len1; var st1:Number = (p1.y-cy)/len1;
				var ct2:Number = (p2.x-cx)/len2; var st2:Number = (p2.y-cy)/len2;
				var ax:Number = st2, ay:Number = -ct2;
				if(ax*ct1+ay*st1 < 0){ax=-ax;ay=-ay;}
				//var dot:Number = ax*fx+ay*fy;
				//fx = dot*ax;
				//fy = dot*ay;
				fx = -k*ax;
				fy = -k*ay;
				//Compute the force due to a difference between the curr radius and actual
				var f2:Number  = s.tension*(p2.radial_distance-len2)*0.01;
				fx -= f2*ct2;
				fy -= f2*st2;
				//End
				if(isNaN(p2.fx) || isNaN(fx))
				{
				 var a=0;
				 a = 5;
				}
				p1.fx += fx; p1.fy += fy;
				p2.fx -= fx; p2.fy -= fy;
				//p1.fx = p1.fy = p2.fx = p2.fy = 0;
				//trace(p2.x.toString()+" "+dn.toString()+k.toString()+" "+ax.toString());
			}
		}
		
	} // end of class SpringForce2
}