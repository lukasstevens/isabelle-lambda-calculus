theory Soundness
  imports Defs
begin

theorem progress: "{} \<turnstile> e : \<tau> \<Longrightarrow> is_v_of_e e \<or> (\<exists>e'. Step e e')"
proof (induction "{} :: \<Gamma>" e \<tau> rule: T.induct)
  case T_UnitI
  then show ?case by simp
next
  case (T_VarI x \<tau>)
  then show ?case by simp
next
  case (T_AbsI x \<tau>1 e \<tau>2)
  then show ?case by simp
next
  case (T_AppI e1 \<tau>1 \<tau>2 e2)
  note IH1 = T_AppI(2)
  note IH2 = T_AppI(4)

  from IH1 show ?case
  proof (elim disjE)
    assume "is_v_of_e e1"
    from IH2 show ?thesis
    proof (elim disjE)
      assume "is_v_of_e e2"
      from \<open>is_v_of_e e1\<close> T_AppI have "\<exists>x e. e1 = (\<lambda>x:\<tau>1. e)" by (metis T.cases \<tau>.inject \<tau>.simps(3) empty_iff is_v_of_e.simps(3))
      then have "\<exists>e'. Step (App e1 e2) e'" using \<open>is_v_of_e e2\<close> ST_BetaI by blast
      then show ?thesis by simp
    next
      assume "\<exists>e2'. Step e2 e2'"
      then show ?thesis using ST_App2I \<open>is_v_of_e e1\<close> by blast
    qed
  next
    assume "\<exists>e1'. Step e1 e1'"
    then obtain e1' where "Step e1 e1'" by blast
    then have "Step (App e1 e2) (App e1' e2)" by (rule ST_AppI)
    then show ?thesis by blast
  qed
qed

definition fve :: "e \<Rightarrow> x set" where
  "fve e \<equiv> set (fve_e e)"

definition closed :: "e \<Rightarrow> bool" where
  "closed x \<equiv> fve x = {}"

declare fve_def[simp]

lemma list_minus_set: "set (list_minus e xs) = set e - set xs"
  by (induction e) (auto)

lemma free_in_context: "\<lbrakk> x \<in> fve e ; \<Gamma> \<turnstile> e : \<tau> \<rbrakk> \<Longrightarrow> \<exists>\<tau>'. (x, \<tau>') \<in> \<Gamma>"
proof (induction e arbitrary: \<Gamma> \<tau> x)
  case (Var y)
  then show ?case using T.cases by fastforce
next
  case (Lam y \<tau>' e)
  then have "x \<noteq> y" by (simp add: list_minus_set)
  then have "x \<in> set (fve_e e)" using list_minus_set T.cases Lam by fastforce
  then show ?case
    by (metis fve_def Lam.IH Lam.prems(2) T.cases \<open>x \<noteq> y\<close> e.distinct(9) e.inject(2) e.simps(11) e.simps(5) insertE prod.inject)
next
  case (App e1 e2)
  then show ?case by (metis fve_def T.cases Un_iff e.simps(11) e.simps(15) e.simps(3) e.simps(7) fve_e.simps(3) set_append)
next
  case Unit
  then show ?case by simp
qed

corollary typeable_closed: "{} \<turnstile> e : \<tau> \<Longrightarrow> closed e"
  unfolding closed_def fve_def
  using free_in_context last_in_set by fastforce

lemma context_invariance: "\<lbrakk> \<Gamma> \<turnstile> e : \<tau> ; \<forall>(x, \<tau>') \<in> \<Gamma>. (x, \<tau>') \<in> \<Gamma>' \<rbrakk> \<Longrightarrow> \<Gamma>' \<turnstile> e : \<tau>"
proof (induction \<Gamma> e \<tau> arbitrary: \<Gamma>' rule: T.induct)
case (T_UnitI \<Gamma>)
  then show ?case by (simp add: T.T_UnitI)
next
  case (T_VarI x \<tau> \<Gamma>)
  then show ?case by (simp add: T.T_VarI)
next
  case (T_AbsI x \<tau>1 \<Gamma> e \<tau>2)
  then show ?case by (simp add: T.T_AbsI)
next
  case (T_AppI \<Gamma> e1 \<tau>1 \<tau>2 e2)
  then show ?case by (meson T.T_AppI)
qed

end