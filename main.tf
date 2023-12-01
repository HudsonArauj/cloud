module "vpc" {
  source           = "./modules/vpc"
  application_name = local.application_name
}


module "iam" {
  source           = "./modules/iam"
  application_name = local.application_name
  
}
module "asg" {
   source = "./modules/asg"
    application_name = local.application_name
    vpc_id           = module.vpc.vpc_id
    public_subnets   = [module.vpc.public_subnet_a_id, module.vpc.public_subnet_b_id]
    profile_name     = module.iam.profile_name
    private_subnet_a_id = module.vpc.private_subnet_a_id
    private_subnet_b_id = module.vpc.private_subnet_b_id
    public_subnet_a_id = module.vpc.public_subnet_a_id
    private_subnet_a = module.vpc.private_subnet_a_id
    private_subnet_b = module.vpc.private_subnet_b_id
    project_db = module.rds.project_db
}

module "rds" {
  source           = "./modules/rds"
  vpc_id = module.vpc.vpc_id
  application_name = local.application_name
  private_subnet_a = module.vpc.private_subnet_a_id
  private_subnet_b = module.vpc.private_subnet_b_id
}