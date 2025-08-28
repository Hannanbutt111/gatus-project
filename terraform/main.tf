module "vpc" {
  source = "./modules/vpc"
}

module "alb" {
  source         = "./modules/alb"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnet_ids
}

module "ecs" {
  source          = "./modules/ecs"
  vpc_id          = module.vpc.vpc_id
  alb_sg          = module.alb.alb_sg_id
  private_subnets = module.vpc.private_subnet_ids
  alb_target_arn  = module.alb.alb_target_arn
}
